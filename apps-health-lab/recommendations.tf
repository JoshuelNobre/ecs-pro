module "recommendations" {
  source       = "../service-module"
  region       = var.region
  cluster_name = var.cluster_name

  service_name   = "nutrition-recommendations"
  service_port   = 30000
  service_cpu    = 256
  service_memory = 512

  task_minimum       = 1
  task_maximum       = 3
  service_task_count = 1

  container_image = "fidelissauro/recommendations-grpc-service:latest"

  use_service_connect  = true
  service_connect_name = data.aws_ssm_parameter.service_connect_name.value
  service_protocol     = "grpc"

  # serviço interno: quem o encontra é o Cloud Map, resolvendo direto para o IP
  # da task. Sem balanceador não há target group nem regra de listener
  use_lb = false

  service_task_execution_role = aws_iam_role.main.arn
  capabilities                = ["FARGATE"]

  service_discovery_namespace = data.aws_ssm_parameter.service_discovery_namespace.value

  # não é usado enquanto use_lb for false, mas descreve como o serviço seria
  # verificado caso um dia entre atrás do balanceador
  service_health_check = {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 10
    interval            = 60
    matcher             = "200-399"
    path                = "/healthz"
    port                = 8080
  }

  # target tracking de CPU: funciona sem balanceador, diferente de
  # requests_tracking, que depende da métrica de requisições por target do ALB
  scale_type         = "cpu_tracking"
  scale_tracking_cpu = 60

  service_launch_type = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 100
    }
  ]

  environment_variables = [
    {
      name  = "ZIPKIN_COLLECTOR_ENDPOINT"
      value = format("http://nutrition-jaeger-collector.%s:9411", var.discovery_domain)
    },
    {
      name  = "PROTEINS_SERVICE_ENDPOINT"
      value = format("nutrition-proteins.%s:30000", var.discovery_domain)
    },
    {
      name  = "WATER_SERVICE_ENDPOINT"
      value = format("nutrition-water.%s:30000", var.discovery_domain)
    },
    {
      name  = "CALORIES_SERVICE_ENDPOINT"
      value = format("nutrition-calories.%s:30000", var.discovery_domain)
    },
    { name  = "version",
      value = timestamp()
    }
  ]

  vpc_id = data.aws_ssm_parameter.vpc.value

  vpc_cidr = data.aws_ssm_parameter.vpc_cidr.value

  private_subnets = [
    data.aws_ssm_parameter.private_subnet_1a.value,
    data.aws_ssm_parameter.private_subnet_1b.value,
    data.aws_ssm_parameter.private_subnet_1c.value,
  ]
}
