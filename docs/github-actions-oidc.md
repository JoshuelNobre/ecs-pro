# Acesso do GitHub Actions à AWS via OIDC

Passo a passo para criar o role que o workflow [`.github/workflows/dev.yml`](../.github/workflows/dev.yml)
assume para aplicar o Terraform e publicar a imagem no ECR.

Com OIDC não existe chave de acesso armazenada no GitHub: a cada execução o
Actions apresenta um token de curta duração e a AWS devolve credenciais
temporárias. O único valor guardado é o ARN do role, que não é sigiloso — por isso fica
como variable, e não como secret.

Este role é o que permite ao CI rodar Terraform, então ele **não pode ser criado
pelo próprio pipeline**. Os comandos abaixo são executados uma vez, localmente,
por alguém com permissão de IAM na conta.

## Valores deste projeto

| | |
|---|---|
| Conta AWS | `550094086634` |
| Repositório | `JoshuelNobre/ecs-pro` |
| Branch que faz deploy | `main` |
| GitHub Environment | `dev` |
| Nome do role | `ecs-pro-github-actions` |
| Variable | `AWS_ROLE_ARN`, dentro do environment `dev` |

## Pré-requisitos

- AWS CLI autenticada com permissão de IAM na conta
- `gh` CLI autenticada, ou acesso às configurações do repositório no GitHub

Confirme em qual conta você está antes de começar:

```bash
aws sts get-caller-identity
```

## 1. Criar o identity provider

Uma vez por conta AWS. Se outro projeto já configurou o GitHub Actions aqui,
pule este passo.

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

Para verificar se já existe:

```bash
aws iam list-open-id-connect-providers
```

> O thumbprint é exigido pela CLI, mas ignorado pela AWS desde 2023 para este
> provider — a validação passou a ser feita pela CA raiz. Não é preciso
> mantê-lo atualizado.

## 2. Criar o role

```bash
cat > /tmp/trust.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::550094086634:oidc-provider/token.actions.githubusercontent.com"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
        "token.actions.githubusercontent.com:sub": "repo:JoshuelNobre/ecs-pro:environment:dev"
      }
    }
  }]
}
EOF

aws iam create-role \
  --role-name ecs-pro-github-actions \
  --assume-role-policy-document file:///tmp/trust.json
```

Para alterar a trust policy de um role que já existe, troque o último comando
por `aws iam update-assume-role-policy` com os mesmos argumentos.

### A condição `sub` é a parte que importa

O identity provider prova apenas que o token veio do GitHub Actions — **não**
de qual repositório. Sem a condição `sub`, qualquer repositório do GitHub, de
qualquer pessoa, pode assumir este role.

Dois cuidados:

- Use `StringEquals`, não `StringLike`. Com `StringLike` e um valor como
  `repo:JoshuelNobre/*`, todos os seus repositórios ganham acesso.
- Nunca omita a condição `sub` "para testar depois".

### O formato do `sub` depende do job

Este é o detalhe que mais causa confusão: o `sub` **muda de formato** conforme
o job declara ou não um environment.

| O job | `sub` que o token carrega |
|---|---|
| não declara environment | `repo:OWNER/REPO:ref:refs/heads/BRANCH` |
| declara `environment: NOME` | `repo:OWNER/REPO:environment:NOME` |

Os jobs deste projeto declaram `environment: dev`, porque é lá que vive a
variable — daí a trust policy acima usar a segunda forma. Se você remover o
`environment:` do workflow, o token passa a apresentar a primeira forma e a
trust policy precisa acompanhar, senão o `AssumeRoleWithWebIdentity` é negado.

Amarrar no environment é mais restritivo que amarrar na branch: em vez de
qualquer job rodando na `main`, só jobs que declaram `dev` conseguem assumir.

### O que está aplicado hoje

Para não depender de acertar o formato exato, a trust policy em uso aceita
qualquer origem dentro deste repositório:

```json
"Condition": {
  "StringEquals": {
    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
  },
  "StringLike": {
    "token.actions.githubusercontent.com:sub": "repo:JoshuelNobre/ecs-pro:*"
  }
}
```

O limite que mais importa continua de pé: nenhum outro repositório do GitHub
consegue assumir o role. O que se abre mão é do isolamento interno — qualquer
branch, environment ou pull request deste repositório passa a ter o mesmo
acesso que a `main`.

Enquanto há um ambiente só e o repositório é seu, a diferença é pequena. Ela
deixa de ser quando existir produção: aí vale voltar ao `StringEquals` da seção
anterior, ou seguir o modelo de um role por ambiente descrito no fim deste
documento.

## 3. Anexar permissões

O pipeline aplica Terraform que cria ECS service, target group, listener rule,
autoscaling, alarmes, log group **e IAM roles** — o `service-module` cria o
execution role da task. Permissão de criar IAM role é, na prática, permissão de
escalar privilégio, então vale escolher conscientemente.

| Opção | Prós | Contras |
|---|---|---|
| `AdministratorAccess` | funciona de primeira | o role vira admin da conta; comprometer o repositório compromete tudo |
| `PowerUserAccess` + IAM restrito | limita o pior caso | exige a policy extra abaixo, senão falha ao criar o execution role |
| Policy sob medida | mínimo privilégio real | trabalhoso; permissões faltando aparecem por tentativa e erro |

A opção do meio, que é a usada aqui:

```bash
aws iam attach-role-policy \
  --role-name ecs-pro-github-actions \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

O `PowerUserAccess` cobre ECS, ECR, ELB, autoscaling, CloudWatch, EC2, SSM e o
state no S3, mas **não** inclui IAM. A policy abaixo devolve só o necessário,
restrito aos roles deste projeto:

```bash
cat > /tmp/iam-limitada.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:TagRole",
      "iam:PutRolePolicy", "iam:DeleteRolePolicy", "iam:GetRolePolicy",
      "iam:AttachRolePolicy", "iam:DetachRolePolicy", "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies", "iam:PassRole"
    ],
    "Resource": "arn:aws:iam::550094086634:role/cluster-ecs-fargate-*"
  }]
}
EOF

aws iam put-role-policy \
  --role-name ecs-pro-github-actions \
  --policy-name ecs-pro-iam \
  --policy-document file:///tmp/iam-limitada.json
```

O `Resource` com prefixo é o que mantém o raio de alcance dentro do projeto: o
pipeline não consegue tocar em roles de outros sistemas na mesma conta.

## 4. Cadastrar a variable no environment

```bash
gh variable set AWS_ROLE_ARN \
  --env dev \
  --body "$(aws iam get-role --role-name ecs-pro-github-actions --query 'Role.Arn' --output text)"
```

Pela interface: **Settings → Environments → dev → Add environment variable**,
com o nome `AWS_ROLE_ARN`.

> **O valor é só o ARN.** Nome e valor são campos separados no GitHub, então
> não repita o nome dentro do valor:
>
> ```
> ✗  AWS_ROLE_ARN=arn:aws:iam::550094086634:role/ecs-pro-github-actions
> ✓  arn:aws:iam::550094086634:role/ecs-pro-github-actions
> ```
>
> O hábito de arquivo `.env`, onde `CHAVE=valor` vai numa linha só, leva
> direto a esse erro. O resultado é um ARN inválido, e a AWS responde
> `Not authorized to perform sts:AssumeRoleWithWebIdentity` — uma mensagem
> que faz procurar o problema em permissões e trust policy.

### Environment e repositório não são o mesmo escopo

Uma variable (ou secret) de environment só é visível para jobs que declarem
aquele environment:

```yaml
jobs:
  deploy:
    environment: dev      # sem isso, vars.AWS_ROLE_ARN vem vazio
```

Uma variable de repositório (**Settings → Secrets and variables → Actions**) é
visível para todos os jobs e dispensa a declaração — mas aí o `sub` do token
volta ao formato de branch, e a trust policy precisa acompanhar.

**O nome precisa bater exatamente, incluindo maiúsculas.** Um workflow que
referencia um environment inexistente não falha: o GitHub cria um novo, vazio.
O job então roda sem a variable, e o erro resultante é idêntico ao de não ter
cadastrado nada — por isso `environment: DEV` contra um environment `dev` é uma
hora perdida garantida.

Se o environment tiver **required reviewers**, cada job que o declara pausa
esperando aprovação. Com três jobs, são três pausas; nesse caso vale declarar o
environment só no `deploy` e deixar a variable também no nível do repositório.

## 5. Verificar

Faça um push na `main` e acompanhe o job `ci-terraform`. O passo
*Configure AWS credentials* deve concluir sem erro — é ele que exercita o
caminho inteiro do OIDC.

## Erros comuns

**`Could not load credentials from any providers`**

Antes de investigar a AWS, olhe os inputs que a action recebeu, no início do log
do passo. O GitHub **omite inputs vazios**, então:

```
with:
  aws-region: us-east-1        ← falta role-to-assume: a variable veio vazia
  audience: sts.amazonaws.com
```

Se `role-to-assume` não aparece, o problema é a variable, não a AWS. Duas
causas: ela não existe, ou vive num environment que o job não declara (veja o
passo 4).

Se `role-to-assume` aparece preenchido, o valor chegou e o problema está
adiante. Confira se ele é **só o ARN**: colar `AWS_ROLE_ARN=arn:aws:...`, no
formato de arquivo `.env`, produz um ARN inválido e a AWS responde com o erro
de autorização abaixo, que aponta para o lugar errado.

**`Not authorized to perform sts:AssumeRoleWithWebIdentity`**

O valor chegou e o token foi emitido, mas a AWS recusou. Note que
isso é a **trust policy** recusando quem está pedindo — não tem relação com as
permissões do passo 3, que só valem depois que o role é assumido. Anexar mais
policies não resolve.

Verifique qual formato o seu job produz, conforme a tabela do passo 2. A
armadilha mais comum: adicionar `environment:` a um job troca o `sub` de
`ref:refs/heads/main` para `environment:DEV`, e uma trust policy escrita para a
branch para de funcionar.

Rodar a partir de um pull request ou de uma tag também gera formatos distintos.

A action tenta várias vezes antes de desistir, então repetições de
`Assuming role with OIDC` no log são só o retry — não indicam falha
intermitente.

**`AccessDenied` em alguma ação de IAM**

O recurso está fora do prefixo `cluster-ecs-fargate-*`. Olhe o ARN na mensagem
antes de ampliar a policy — na maioria das vezes é um nome novo que passou a ser
criado, não uma permissão genuinamente faltando.

## Quando houver mais de um ambiente

Hoje tudo sai da `main` e aplica em `dev`, com o diretório de tfvars fixado na
variável `ENVIRONMENT` do workflow e o GitHub Environment fixado como `DEV`.

Ao separar os ambientes, o caminho mais seguro é **um role por ambiente**, cada
um com a trust policy amarrada ao seu próprio environment:

| Ambiente | Role | `sub` esperado |
|---|---|---|
| dev | `ecs-pro-github-actions-dev` | `repo:JoshuelNobre/ecs-pro:environment:dev` |
| prod | `ecs-pro-github-actions-prod` | `repo:JoshuelNobre/ecs-pro:environment:prod` |

Cada environment guarda seu próprio `AWS_ROLE_ARN`, então o workflow não muda —
o mesmo `${{ secrets.AWS_ROLE_ARN }}` resolve para um role diferente conforme o
environment do job. Um deploy de dev não consegue tocar em produção, porque o
token que ele apresenta nem serve para assumir o role de lá.

Dois ajustes no workflow:

- Trocar a variável `ENVIRONMENT` por `${{ github.ref_name }}`, para o
  `-var-file` seguir a branch
- Trocar `environment: DEV` por `${{ github.ref_name }}`, lembrando que o nome
  do environment terá de bater com o da branch, maiúsculas incluídas — o que é
  um bom motivo para renomear `DEV` para `dev` antes de chegar lá

Evite resolver isso com um `StringLike` e `refs/heads/*` num role único: seria
mais simples de escrever e daria a qualquer branch o mesmo acesso que produção.
