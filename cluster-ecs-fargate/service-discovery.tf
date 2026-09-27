resource "aws_service_discovery_private_dns_namespace" "service_discovery_namespace" {
  name        = format("%s.local.com", var.project_name)
  description = format("Private DNS namespace for %s", var.project_name)
  vpc         = data.aws_ssm_parameter.vpc_id.value
}

resource "aws_service_discovery_private_dns_namespace" "service_connect" {
  name        = format("%s.local-connect.com", var.project_name)
  description = format("Private DNS namespace for %s", var.project_name)
  vpc         = data.aws_ssm_parameter.vpc_id.value
}