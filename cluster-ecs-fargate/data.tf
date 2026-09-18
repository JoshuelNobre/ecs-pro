data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_vpc_id
}

data "aws_ssm_parameter" "vpc_cidr" {
  name = var.ssm_vpc_cidr
}

data "aws_ssm_parameter" "public_subnet_1a_id" {
  name = var.ssm_public_subnet_1a_id
}

data "aws_ssm_parameter" "public_subnet_1b_id" {
  name = var.ssm_public_subnet_1b_id
}

data "aws_ssm_parameter" "public_subnet_1c_id" {
  name = var.ssm_public_subnet_1c_id
}

data "aws_ssm_parameter" "private_subnet_1a_id" {
  name = var.ssm_private_subnet_1a_id
}

data "aws_ssm_parameter" "private_subnet_1b_id" {
  name = var.ssm_private_subnet_1b_id
}

data "aws_ssm_parameter" "private_subnet_1c_id" {
  name = var.ssm_private_subnet_1c_id
}