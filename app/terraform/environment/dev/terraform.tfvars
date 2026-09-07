region         = "us-east-1"
cluster_name   = "cluster-ecs-ec2"
service_name   = "app-service"
service_port   = 8080
service_cpu    = 256
service_memory = 512

service_launch_type = "EC2"

service_task_count    = 3
ssm_listener          = "/cluster-ecs-ec2/lb-listener-arn"
ssm_vpc_id            = "/ecs-pro-network/vpc-id"
ssm_private_subnet_1a = "/ecs-pro-network/private-subnet-1a-id"
ssm_private_subnet_1b = "/ecs-pro-network/private-subnet-1b-id"
ssm_private_subnet_1c = "/ecs-pro-network/private-subnet-1c-id"
service_hosts         = ["app-service.joshuel.com"]

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

capabilities = ["EC2"]

service_health_check = {
  path                = "/healthcheck"
  interval            = 30
  timeout             = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
  matcher             = "200-399"
  port                = 8080
}
