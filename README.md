# ecs-lab

Infraestrutura em Terraform para rodar serviços no ECS Fargate, da VPC até a
porta de entrada. Construído acompanhando um curso de containers, então o foco
é entender cada peça — não é uma referência de produção.

## O que tem aqui

```
network/              VPC, subnets pública/privada/database, NAT, IGW
cluster-ecs-fargate/  cluster ECS, ALB público e interno, NLB + VPC Link,
                      namespaces de Cloud Map e Service Connect
service-module/       módulo reutilizável: task definition, serviço, target
                      group, autoscaling, service discovery, CodeDeploy
api-gateway/          REST API com custom domain, DNS no Cloudflare
app/                  aplicação Go com pipeline própria
app-pudim/            serviço de uma imagem pública, sem build
apps-health-lab/      8 microserviços com gRPC e tracing distribuído
cluster-ecs-ec2/      cluster EC2, do começo do curso (não usado)
```

Os módulos conversam por **Parameter Store**: cada um publica o que o próximo
precisa (`/<project_name>/vpc-id`, `/<project_name>/lb-listener-arn`, …), e
quem consome lê pelo nome. É o que permite trocar o balanceador de um serviço
mudando uma linha de tfvars.

## Subir

```bash
./deploy.sh dev apply          # network + cluster
cd apps-health-lab && terraform apply -var-file=environment/dev/terraform.tfvars

export CLOUDFLARE_API_TOKEN='...'
cd ../api-gateway && terraform apply -var-file=environment/dev/terraform.tfvars
```

A ordem importa: cada camada lê os parâmetros publicados pela anterior.

A aplicação Go é o único módulo que não sobe por `terraform apply` direto — ela
precisa da imagem construída antes, e quem faz isso é `app/pipeline.sh` ou o
workflow em `.github/workflows/dev.yml`.

## Derrubar

```bash
export CLOUDFLARE_API_TOKEN='...'
./deploy.sh dev destroy
```

Destrói os seis módulos na ordem inversa, remove os log groups que a AWS cria
sozinha (Container Insights e execution logs do API Gateway, que não pertencem
a recurso nenhum do Terraform) e conta o que sobrou.

Ficam de pé de propósito: o repositório ECR com as imagens, a role do GitHub
Actions e o bucket de state.

## O que vale olhar

| | |
|---|---|
| `service-module/` | um módulo serve três consumidores diferentes; o que varia vai por variável |
| `use_lb = false` | serviço interno não cria target group nem regra de listener |
| `deployment_controller` | alterna entre rolling deployment e blue/green com CodeDeploy |
| Cloud Map e Service Connect | dois mecanismos de descoberta convivendo, com desenhos diferentes |
| `docs/github-actions-oidc.md` | autenticação da pipeline sem chave de acesso |

## Pré-requisitos

Terraform 1.14+, AWS CLI com credenciais, e um bucket S3 para o state —
configurado em cada `environment/dev/backend.tfvars`. O `api-gateway` também
precisa de um token do Cloudflare com `Zone.DNS: Edit`, lido de
`CLOUDFLARE_API_TOKEN`.
