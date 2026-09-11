#!/bin/bash

set -e

ENV="${1:-dev}"
ACTION="${2:-apply}"

# No apply cuida apenas da plataforma: o deploy do app é do pipeline.sh, que
# constrói a imagem e aplica o módulo passando a tag do commit.
PLATAFORMA=("network" "cluster-ecs-fargate")

# No destroy o app entra junto, primeiro de todos — ele consome o listener e os
# SSM Parameters do cluster, que por sua vez consome os da rede.
DESTROY=("app/terraform" "cluster-ecs-fargate" "network")

run() {
  local module=$1
  local extra=()

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

terraform fmt --recursive

if [ "${ACTION}" = "destroy" ]; then
  echo ""
  echo "ATENÇÃO: isso derruba o app, o cluster e a rede do ambiente ${ENV}."
  read -p "Digite 'destroy' para confirmar: " confirma
  [ "${confirma}" = "destroy" ] || {
    echo "cancelado."
    exit 1
  }

  for module in "${DESTROY[@]}"; do
    run "${module}"
  done

  echo ""
  echo "Não gerenciados pelo Terraform, remova à mão se for o caso:"
  echo "  - repositório ECR (criado pelo pipeline, contém as imagens)"
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
