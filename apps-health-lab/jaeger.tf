module "jaeger" {
  source       = "../service-module"
  region       = var.region
  cluster_name = var.cluster_name

  service_name   = "nutrition-jaeger-collector"
  service_port   = 9411
  service_cpu    = 256
  service_memory = 512

  task_minimum       = 1
  task_maximum       = 1
  service_task_count = 1

  container_image = "jaegertracing/all-in-one:1.57"

  use_service_connect  = true
  service_connect_name = data.aws_ssm_parameter.service_connect_name.value
  service_connect_arn  = data.aws_ssm_parameter.service_connect_arn.value
  service_protocol     = "http"

  # coletor de traces: recebe dos outros serviços por dentro da rede, então é
  # alcançado pelo Cloud Map e não precisa de balanceador
  use_lb = false

  service_task_execution_role = aws_iam_role.main.arn
  capabilities                = ["FARGATE"]

  service_discovery_namespace = data.aws_ssm_parameter.service_discovery_namespace.value

  service_health_check = {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 10
    interval            = 60
    matcher             = "200-399"
    path                = "/"
    port                = 9411
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
      name  = "COLLECTOR_ZIPKIN_HOST_PORT"
      value = ":9411"
    }
  ]

  vpc_id = data.aws_ssm_parameter.vpc.value

  private_subnets = [
    data.aws_ssm_parameter.private_subnet_1a.value,
    data.aws_ssm_parameter.private_subnet_1b.value,
    data.aws_ssm_parameter.private_subnet_1c.value,
  ]
}
