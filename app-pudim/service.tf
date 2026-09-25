module "pudim" {
  source = "../service-module"

  region         = var.region
  cluster_name   = var.cluster_name
  service_name   = var.service_name
  service_port   = 80
  service_cpu    = 256
  service_memory = 512

  service_listener            = data.aws_ssm_parameter.lb_listener_arn.value
  alb_arn                     = data.aws_ssm_parameter.alb_arn.value
  service_task_execution_role = aws_iam_role.main.arn

  service_health_check = {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 10
    interval            = 60
    matcher             = "200-399"
    path                = "/"
    port                = 80
  }

  service_launch_type = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 100
    }
  ]

  service_hosts = var.service_hosts

  # imagem pública do Docker Hub: este serviço não tem build nem repositório
  # próprio, o Fargate puxa direto na hora de subir a task
  container_image = "fidelissauro/pudim:latest"

  vpc_id = data.aws_ssm_parameter.vpc_id.value
  private_subnets = [
    data.aws_ssm_parameter.private_subnet_1a.value,
    data.aws_ssm_parameter.private_subnet_1b.value,
    data.aws_ssm_parameter.private_subnet_1c.value,
  ]

  environment_variables = []
  capabilities          = ["FARGATE"]

  service_task_count = 1
  task_minimum       = 1
  task_maximum       = 1

  service_discovery_namespace = data.aws_ssm_parameter.service_discovery_namespace.value
}
