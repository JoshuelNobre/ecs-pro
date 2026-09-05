resource "aws_ssm_parameter" "vpc_id" {
  name  = format("/%s/vpc-id", var.project_name)
  type  = "String"
  value = aws_vpc.main.id
}

resource "aws_ssm_parameter" "public_subnet_1a_id" {
  name  = format("/%s/public-subnet-1a-id", var.project_name)
  type  = "String"
  value = aws_subnet.public_subnet_1a.id
}

resource "aws_ssm_parameter" "public_subnet_1b_id" {
  name  = format("/%s/public-subnet-1b-id", var.project_name)
  type  = "String"
  value = aws_subnet.public_subnet_1b.id
}

resource "aws_ssm_parameter" "public_subnet_1c_id" {
  name  = format("/%s/public-subnet-1c-id", var.project_name)
  type  = "String"
  value = aws_subnet.public_subnet_1c.id
}

resource "aws_ssm_parameter" "private_subnet_1a_id" {
  name  = format("/%s/private-subnet-1a-id", var.project_name)
  type  = "String"
  value = aws_subnet.private_subnet_1a.id
}

resource "aws_ssm_parameter" "private_subnet_1b_id" {
  name  = format("/%s/private-subnet-1b-id", var.project_name)
  type  = "String"
  value = aws_subnet.private_subnet_1b.id
}

resource "aws_ssm_parameter" "private_subnet_1c_id" {
  name  = format("/%s/private-subnet-1c-id", var.project_name)
  type  = "String"
  value = aws_subnet.private_subnet_1c.id
}

resource "aws_ssm_parameter" "database_subnet_1a_id" {
  name  = format("/%s/database-subnet-1a-id", var.project_name)
  type  = "String"
  value = aws_subnet.database_subnet_1a.id
}

resource "aws_ssm_parameter" "database_subnet_1b_id" {
  name  = format("/%s/database-subnet-1b-id", var.project_name)
  type  = "String"
  value = aws_subnet.database_subnet_1b.id
}

resource "aws_ssm_parameter" "database_subnet_1c_id" {
  name  = format("/%s/database-subnet-1c-id", var.project_name)
  type  = "String"
  value = aws_subnet.database_subnet_1c.id
}

resource "aws_ssm_parameter" "vpc_cidr" {
  name  = format("/%s/vpc-cidr", var.project_name)
  type  = "String"
  value = aws_vpc.main.cidr_block
}