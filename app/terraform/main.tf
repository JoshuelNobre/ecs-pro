module "service" {
  source = "../../service-module"

  cluster_name                = var.cluster_name
  service_name                = var.service_name
  service_port                = var.service_port
  service_cpu                 = var.service_cpu
  service_memory              = var.service_memory
  service_listener            = var.ssm_listener
  service_task_execution_role = aws_iam_role.main.arn
  vpc_id                      = var.ssm_vpc_id
  private_subnets = [
    data.aws_ssm_parameter.private_subnet_1a.value,
    data.aws_ssm_parameter.private_subnet_1b.value,
    data.aws_ssm_parameter.private_subnet_1c.value
  ]
}