# Acesso do GitHub Actions à AWS via OIDC

Passo a passo para criar o role que o workflow [`.github/workflows/dev.yml`](../.github/workflows/dev.yml)
assume para aplicar o Terraform e publicar a imagem no ECR.

Com OIDC não existe chave de acesso armazenada no GitHub: a cada execução o
Actions apresenta um token de curta duração e a AWS devolve credenciais
temporárias. O único secret no repositório é o ARN do role, que não é sigiloso.

Este role é o que permite ao CI rodar Terraform, então ele **não pode ser criado
pelo próprio pipeline**. Os comandos abaixo são executados uma vez, localmente,
por alguém com permissão de IAM na conta.

## Valores deste projeto

| | |
|---|---|
| Conta AWS | `550094086634` |
| Repositório | `JoshuelNobre/ecs-pro` |
| Branch que faz deploy | `main` |
| Nome do role | `ecs-pro-github-actions` |
| Secret no GitHub | `AWS_ROLE_ARN` |

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
        "token.actions.githubusercontent.com:sub": "repo:JoshuelNobre/ecs-pro:ref:refs/heads/main"
      }
    }
  }]
}
EOF

aws iam create-role \
  --role-name ecs-pro-github-actions \
  --assume-role-policy-document file:///tmp/trust.json
```

### A condição `sub` é a parte que importa

O identity provider prova apenas que o token veio do GitHub Actions — **não**
de qual repositório. Sem a condição `sub`, qualquer repositório do GitHub, de
qualquer pessoa, pode assumir este role.

Dois cuidados:

- Use `StringEquals`, não `StringLike`. Com `StringLike` e um valor como
  `repo:JoshuelNobre/*`, todos os seus repositórios ganham acesso.
- Nunca omita a condição `sub` "para testar depois".

O formato é `repo:OWNER/REPO:ref:refs/heads/BRANCH`.

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

## 4. Cadastrar o secret no GitHub

```bash
gh secret set AWS_ROLE_ARN \
  --body "$(aws iam get-role --role-name ecs-pro-github-actions --query 'Role.Arn' --output text)"
```

Pela interface: **Settings → Secrets and variables → Actions → New repository
secret**, com o nome `AWS_ROLE_ARN`.

## 5. Verificar

Faça um push na `main` e acompanhe o job `ci-terraform`. O passo
*Configure AWS credentials* deve concluir sem erro — é ele que exercita o
caminho inteiro do OIDC.

## Erros comuns

**`Credentials could not be loaded` ou nenhum token OIDC disponível**

Falta `permissions: id-token: write` no workflow. Sem isso o GitHub não emite o
token, e a mensagem não deixa claro o que faltou. Já está configurado no
`dev.yml`, mas é o primeiro lugar a olhar se você criar outro workflow.

**`Not authorized to perform sts:AssumeRoleWithWebIdentity`**

A condição `sub` não bate com o que o Actions enviou. Confira o owner, o nome do
repositório e a branch — o valor precisa ser idêntico, incluindo maiúsculas.
Executar a partir de um pull request ou de uma tag gera um `sub` com formato
diferente de `ref:refs/heads/...`.

**`AccessDenied` em alguma ação de IAM**

O recurso está fora do prefixo `cluster-ecs-fargate-*`. Olhe o ARN na mensagem
antes de ampliar a policy — na maioria das vezes é um nome novo que passou a ser
criado, não uma permissão genuinamente faltando.

## Quando houver mais de um ambiente

Hoje tudo sai da `main` e aplica em `dev`, com o ambiente fixado na variável
`ENVIRONMENT` do workflow. Ao separar os ambientes por branch, dois ajustes:

- No workflow, trocar `ENVIRONMENT` por `${{ github.ref_name }}`
- Na trust policy, aceitar as branches correspondentes — aí sim com
  `StringLike` e `repo:JoshuelNobre/ecs-pro:ref:refs/heads/*`, ou uma lista
  explícita de valores no `StringEquals`

O mais seguro é um role por ambiente, cada um amarrado à sua branch, para que um
deploy de `dev` não tenha permissão sobre produção.
