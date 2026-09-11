#!/bin/bash

set -e

ENV="${1:-dev}"
ACTION="${2:-apply}"

# apenas a plataforma: o deploy do app é do pipeline.sh, que constrói a imagem
# e aplica o módulo passando a tag do commit
MODULES=("network" "cluster-ecs-fargate")

run() {
  local module=$1

  echo ""
  echo ">>> ${ACTION} ${module} (${ENV})"

  (
    cd "${module}"
    terraform init -reconfigure --backend-config=environment/${ENV}/backend.tfvars
    terraform ${ACTION} --auto-approve -var-file=environment/${ENV}/terraform.tfvars
  )
}

terraform fmt --recursive

if [ "${ACTION}" = "destroy" ]; then
  # ordem inversa: o cluster consome os SSM Parameters da rede
  for ((i = ${#MODULES[@]} - 1; i >= 0; i--)); do
    run "${MODULES[$i]}"
  done
else
  for module in "${MODULES[@]}"; do
    run "${module}"
  done
fi

echo ""
echo "OK: ${ACTION} finalizado."
