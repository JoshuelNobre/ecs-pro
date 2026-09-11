data "aws_ssm_parameter" "lb_listener_arn" {
  name = var.ssm_listener
}

data "aws_ssm_parameter" "vpc_id" {
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

data "aws_ssm_parameter" "alb_arn" {
  name = var.ssm_alb_arn
}

data "aws_ssm_parameter" "vpc_cidr" {
  name = var.ssm_vpc_cidr
}