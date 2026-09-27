data "aws_ssm_parameter" "vpc" {
  name = var.ssm_vpc_id
}

data "aws_ssm_parameter" "private_subnet_1a" {
  name = var.ssm_private_subnet_1a
}

data "aws_ssm_parameter" "private_subnet_1b" {
  name = var.ssm_private_subnet_1b
}

data "aws_ssm_parameter" "private_subnet_1c" {
  name = var.ssm_private_subnet_1c
}

// só a health-api entra por balanceador; os demais serviços falam entre si pelo
// Cloud Map e não têm target group. Os dois pares ficam disponíveis para que
// trocar entrada pública por privada seja uma linha em health-api.tf
data "aws_ssm_parameter" "listener" {
  name = var.ssm_listener
}

data "aws_ssm_parameter" "alb" {
  name = var.ssm_alb
}

data "aws_ssm_parameter" "listener_internal" {
  name = var.ssm_listener_internal
}

data "aws_ssm_parameter" "alb_internal" {
  name = var.ssm_alb_internal
}

data "aws_ssm_parameter" "service_discovery_namespace" {
  name = var.ssm_service_discovery_namespace
}

data "aws_ssm_parameter" "service_connect_name" {
  name = var.ssm_service_connect_name
}

data "aws_ssm_parameter" "service_connect_arn" {
  name = var.ssm_service_connect_arn
}