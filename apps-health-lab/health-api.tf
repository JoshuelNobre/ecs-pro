module "health_api" {
  source       = "../service-module"
  region       = var.region
  cluster_name = var.cluster_name

  service_name   = "nutrition-health-api"
  service_port   = 8080
  service_cpu    = 256
  service_memory = 512

  task_minimum       = 1
  task_maximum       = 3
  service_task_count = 1

  container_image = "fidelissauro/health-api:latest"

  # a AWS não permite Service Connect com o controller CODE_DEPLOY. Não faz
  # falta aqui: as chamadas aos outros serviços saem pelos endereços do Cloud
  # Map, e ninguém chama a health-api por dentro da malha
  use_service_connect = false
  service_protocol    = "http"

  # única porta de entrada do lab: recebe de fora e orquestra as chamadas gRPC
  # para os demais serviços. Para fechar o lab na VPC, trocar os dois pelos
  # data sources listener_internal/alb_internal
  service_listener = data.aws_ssm_parameter.listener_internal.value
  alb_arn          = data.aws_ssm_parameter.alb_internal.value

  service_task_execution_role = aws_iam_role.main.arn
  capabilities                = ["FARGATE"]

  service_discovery_namespace = data.aws_ssm_parameter.service_discovery_namespace.value

  service_hosts = [
    # format("health.%s", var.ingress_domain),
    "health.jonoma-it.internal.com"
  ]

  deployment_controller = "CODE_DEPLOY"

  codedeploy_strategy = "CodeDeployDefault.ECSLinear10PercentEvery1Minutes"

  service_health_check = {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 10
    interval            = 60
    matcher             = "200-399"
    path                = "/healthcheck"
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
      name  = "BMR_SERVICE_ENDPOINT"
      value = format("nutrition-bmr.%s:30000", var.discovery_domain)
    },
    {
      name  = "IMC_SERVICE_ENDPOINT"
      value = format("nutrition-imc.%s:30000", var.discovery_domain)
    },
    {
      name  = "RECOMMENDATIONS_SERVICE_ENDPOINT"
      value = format("nutrition-recommendations.%s:30000", var.discovery_domain)
    },
    { name  = "version",
      value = timestamp()
    }
  ]

  vpc_id = data.aws_ssm_parameter.vpc.value

  private_subnets = [
    data.aws_ssm_parameter.private_subnet_1a.value,
    data.aws_ssm_parameter.private_subnet_1b.value,
    data.aws_ssm_parameter.private_subnet_1c.value,
  ]
}
