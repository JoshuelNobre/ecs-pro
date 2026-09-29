#!/bin/bash

set -e

ENV="${1:-dev}"
ACTION="${2:-apply}"

# No apply cuida apenas da plataforma: o deploy do app é do pipeline.sh, que
# constrói a imagem e aplica o módulo passando a tag do commit.
PLATAFORMA=("network" "cluster-ecs-fargate")

# No destroy tudo entra, do mais externo para o mais interno: cada um consome os
# SSM Parameters e o listener do anterior.
DESTROY=(
  "api-gateway"
  "apps-health-lab"
  "app-pudim"
  "app/terraform"
  "cluster-ecs-fargate"
  "network"
)

run() {
  local module=$1
  local extra=()

  [ -d "${module}" ] || {
    echo ">>> ${module} não existe, pulando"
    return
  }

  # container_image não tem default e é obrigatório mesmo para destruir, já que
  # o Terraform precisa avaliar a configuração. O valor é irrelevante aqui.
  [ "${module}" = "app/terraform" ] && extra=(-var "container_image=unused-on-destroy")

  echo ""
  echo ">>> ${ACTION} ${module} (${ENV})"

  (
    cd "${module}"
    terraform init -reconfigure --backend-config=environment/${ENV}/backend.tfvars
    terraform ${ACTION} --auto-approve \
      -var-file=environment/${ENV}/terraform.tfvars "${extra[@]}"
  )
}

# A AWS cria estes log groups sozinha, no primeiro uso do serviço, e eles não
# pertencem a nenhum recurso do Terraform: ficam para trás a cada destroy e vão
# se acumulando com o nome de clusters e APIs que não existem mais.
varre_log_groups() {
  echo ""
  echo ">>> varrendo log groups criados pela AWS"

  for prefixo in "/aws/ecs/containerinsights/" "API-Gateway-Execution-Logs_"; do
    aws logs describe-log-groups \
      --log-group-name-prefix "${prefixo}" \
      --query "logGroups[].logGroupName" --output text 2>/dev/null |
      tr '\t' '\n' | grep . | while read -r grupo; do
      echo "    removendo ${grupo}"
      aws logs delete-log-group --log-group-name "${grupo}" || true
    done
  done
}

confere_sobras() {
  echo ""
  echo ">>> conferindo o que sobrou"
  printf '    VPCs .............. %s\n' "$(aws ec2 describe-vpcs --filters Name=is-default,Values=false --query 'length(Vpcs)' --output text)"
  printf '    NAT gateways ...... %s\n' "$(aws ec2 describe-nat-gateways --filter Name=state,Values=available,pending --query 'length(NatGateways)' --output text)"
  printf '    Elastic IPs ....... %s\n' "$(aws ec2 describe-addresses --query 'length(Addresses)' --output text)"
  printf '    Load balancers .... %s\n' "$(aws elbv2 describe-load-balancers --query 'length(LoadBalancers)' --output text)"
  printf '    Target groups ..... %s\n' "$(aws elbv2 describe-target-groups --query 'length(TargetGroups)' --output text)"
  printf '    Clusters ECS ...... %s\n' "$(aws ecs list-clusters --query 'length(clusterArns)' --output text)"
  printf '    APIs Gateway ...... %s\n' "$(aws apigateway get-rest-apis --query 'length(items)' --output text)"
  printf '    Log groups ........ %s\n' "$(aws logs describe-log-groups --query 'length(logGroups)' --output text)"
}

terraform fmt --recursive

if [ "${ACTION}" = "destroy" ]; then
  echo ""
  echo "ATENÇÃO: isso derruba TUDO do ambiente ${ENV}:"
  printf '  - %s\n' "${DESTROY[@]}"
  read -p "Digite 'destroy' para confirmar: " confirma
  [ "${confirma}" = "destroy" ] || {
    echo "cancelado."
    exit 1
  }

  # o módulo api-gateway declara o provider do Cloudflare, que exige o token
  # mesmo para destruir
  [ -n "${CLOUDFLARE_API_TOKEN}" ] || {
    echo "erro: exporte CLOUDFLARE_API_TOKEN antes de destruir o api-gateway."
    exit 1
  }

  for module in "${DESTROY[@]}"; do
    run "${module}"
  done

  varre_log_groups
  confere_sobras

  echo ""
  echo "Mantidos de propósito, remova à mão só se for encerrar o projeto:"
  echo "  - repositório ECR com as imagens"
  echo "      aws ecr delete-repository --repository-name linuxtips/ecs-pro-app --force"
  echo "  - role e identity provider do GitHub Actions (docs/github-actions-oidc.md)"
  echo "  - bucket de state s3://ecs-pro-states"
else
  for module in "${PLATAFORMA[@]}"; do
    run "${module}"
  done
fi

echo ""
echo "OK: ${ACTION} finalizado."
