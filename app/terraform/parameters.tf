resource "aws_ssm_parameter" "teste" {
  name  = format("/%s/%s", "example-parameter", var.service_name)
  type  = "String"
  value = "Vim do Parameter Store v1"
}