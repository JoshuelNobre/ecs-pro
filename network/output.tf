output "ssm_vpc_id" {
  value = aws_ssm_parameter.vpc_id
  sensitive = true
}

output "ssm_public_subnet_1a_id" {
  value = aws_ssm_parameter.public_subnet_1a_id
  sensitive = true
}

output "ssm_public_subnet_1b_id" {
  value = aws_ssm_parameter.public_subnet_1b_id
  sensitive = true
}

output "ssm_public_subnet_1c_id" {
  value = aws_ssm_parameter.public_subnet_1c_id
  sensitive = true
}

output "ssm_private_subnet_1a_id" {
  value = aws_ssm_parameter.private_subnet_1a_id
  sensitive = true
}

output "ssm_private_subnet_1b_id" {
  value = aws_ssm_parameter.private_subnet_1b_id
  sensitive = true
}

output "ssm_private_subnet_1c_id" {
  value = aws_ssm_parameter.private_subnet_1c_id
  sensitive = true
}

output "ssm_database_subnet_1a_id" {
  value = aws_ssm_parameter.database_subnet_1a_id
  sensitive = true
}

output "ssm_database_subnet_1b_id" {
  value = aws_ssm_parameter.database_subnet_1b_id
  sensitive = true
}

output "ssm_database_subnet_1c_id" {
  value = aws_ssm_parameter.database_subnet_1c_id
  sensitive = true
}