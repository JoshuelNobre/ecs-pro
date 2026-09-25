region         = "us-east-1"
cluster_name   = "jonoma-it"
service_name   = "app-service"
service_port   = 8080
service_cpu    = 256
service_memory = 512

service_launch_type = [
  {
    capacity_provider = "FARGATE"
    weight            = 50
  },
  {
    capacity_provider = "FARGATE_SPOT"
    weight            = 50
  }
]

service_task_count = 3

# ssm_listener          = "/jonoma-it/lb-listener-arn"
# ssm_alb_arn           = "/jonoma-it/lb-arn"

ssm_listener = "/jonoma-it/lb-internal-listener-arn"
ssm_alb_arn  = "/jonoma-it/lb-internal-arn"

ssm_vpc_id            = "/jonoma-it/vpc-id"
ssm_vpc_cidr          = "/jonoma-it/vpc-cidr"
ssm_private_subnet_1a = "/jonoma-it/private-subnet-1a-id"
ssm_private_subnet_1b = "/jonoma-it/private-subnet-1b-id"
ssm_private_subnet_1c = "/jonoma-it/private-subnet-1c-id"
service_hosts = [
  # "app-service.joshuel.com"
  "app.jonoma-it.internal.com"
]
ssm_service_discovery_namespace = "/jonoma-it/cloudmap/namespace"
environment_variables = [
  {
    name  = "ENVIRONMENT"
    value = "dev"
  },
  {
    name  = "LOG_LEVEL"
    value = "debug"
  },
]

capabilities = ["FARGATE"]

service_health_check = {
  path                = "/healthcheck"
  interval            = 30
  timeout             = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
  matcher             = "200-399"
  port                = 8080
}

scale_type = "requests_tracking"

task_minimum = 3

task_maximum = 12

# Autoscaling cpu


scale_out_cpu_threshold       = 70
scale_out_adjustment          = 2
scale_out_comparison_operator = "GreaterThanOrEqualToThreshold"
scale_out_statistic           = "Average"
scale_out_period              = 60
scale_out_evaluation_periods  = 2
scale_out_cooldown            = 60

#

scale_in_cpu_threshold       = 30
scale_in_adjustment          = -1
scale_in_comparison_operator = "LessThanOrEqualToThreshold"
scale_in_statistic           = "Average"
scale_in_period              = 60
scale_in_evaluation_periods  = 2
scale_in_cooldown            = 60
scale_tracking_cpu           = 50
scale_tracking_request       = 100
