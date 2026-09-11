#!/bin/bash

# SETUP INICIAL
set -e

# roda a partir do diretório do próprio script, não do cwd de quem chamou
cd "$(dirname "$0")"

ENVIRONMENT="${1:-dev}"

# go install grava em $GOPATH/bin, que não está no PATH por padrão
export PATH="$(go env GOPATH)/bin:$PATH"

export AWS_PAGER=""
export AWS_REGION="us-east-1"
export AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)

export APP_NAME="ecs-pro-app"
export REPOSITORY_NAME="linuxtips/$APP_NAME"
export REGISTRY="$AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com"

TFVARS="terraform/environment/$ENVIRONMENT/terraform.tfvars"

# cluster e serviço saem do tfvars para não divergirem do que o Terraform cria
tfvar() {
  grep -oP "^$1\s*=\s*\"\K[^\"]+" "$TFVARS"
}

export CLUSTER_NAME=$(tfvar cluster_name)
export SERVICE_NAME=$(tfvar service_name)

# CI DA APP

echo "APP - CI"

cd app/

echo "APP - LINT"
go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.59.1
golangci-lint run ./... -E errcheck

echo "APP - TEST"
go test -v ./...

# CI DO TERRAFORM

echo "TERRAFORM - CI"

cd ../terraform

echo "TERRAFORM - FORMAT CHECK"
terraform fmt --recursive --check

terraform init -backend-config=environment/$ENVIRONMENT/backend.tfvars

echo "TERRAFORM - VALIDATE"
terraform validate

# BUILD APP

cd ../app

echo "BUILD - BUMP DE VERSAO"

GIT_COMMIT_HASH=$(git rev-parse --short HEAD)
echo $GIT_COMMIT_HASH

echo "BUILD - LOGIN NO ECR"

aws ecr get-login-password --region $AWS_REGION |
  docker login --username AWS --password-stdin $REGISTRY

echo "BUILD - CREATE ECR IF NOT EXISTS"

# o repositório é do pipeline, não do Terraform: a imagem precisa existir
# antes do apply, e o Terraform só recebe a URL pronta
if aws ecr describe-repositories --repository-names $REPOSITORY_NAME >/dev/null 2>&1; then
  echo "Repositório $REPOSITORY_NAME já existe."
else
  echo "Repositório $REPOSITORY_NAME não encontrado. Criando..."
  aws ecr create-repository \
    --repository-name $REPOSITORY_NAME \
    --image-scanning-configuration scanOnPush=true
fi

echo "BUILD - DOCKER BUILD"

REPOSITORY_TAG=$REGISTRY/$REPOSITORY_NAME:$GIT_COMMIT_HASH

docker build -t $REPOSITORY_TAG .

# PUBLISH APP

echo "BUILD - DOCKER PUBLISH"

docker push $REPOSITORY_TAG

# APPLY DO TERRAFORM - CD

cd ../terraform

echo "DEPLOY - TERRAFORM PLAN"
terraform plan \
  -var-file=environment/$ENVIRONMENT/terraform.tfvars \
  -var container_image=$REPOSITORY_TAG

echo "DEPLOY - TERRAFORM APPLY"
terraform apply --auto-approve \
  -var-file=environment/$ENVIRONMENT/terraform.tfvars \
  -var container_image=$REPOSITORY_TAG

echo "DEPLOY - WAIT DEPLOY"

aws ecs wait services-stable \
  --cluster $CLUSTER_NAME \
  --services $SERVICE_NAME \
  --region $AWS_REGION

echo ""
echo "OK: $SERVICE_NAME em $REPOSITORY_TAG"
