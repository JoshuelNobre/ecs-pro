#!/bin/bash

set -e

ENV="${1:-dev}"
ACTION="${2:-apply}"

MODULES=("network" "cluster-ecs-ec2")

run() {
  local module=$1

  echo ""
  echo ">>> ${ACTION} ${module} (${ENV})"

  cd "${module}"

  terraform init -reconfigure --backend-config=environment/${ENV}/backend.tfvars
  terraform ${ACTION} --auto-approve -var-file=environment/${ENV}/terraform.tfvars

  cd ..
}

terraform fmt --recursive

if [ "${ACTION}" = "destroy" ]; then
  # destrói na ordem inversa: cluster primeiro, depois network
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
