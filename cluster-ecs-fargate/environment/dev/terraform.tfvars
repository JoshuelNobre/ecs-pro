project_name = "cluster-ecs-fargate"
region       = "us-east-1"

# SSM VPC Parameters
ssm_vpc_id              = "/ecs-pro-network/vpc-id"
ssm_vpc_cidr            = "/ecs-pro-network/vpc-cidr"
ssm_public_subnet_1a_id = "/ecs-pro-network/public-subnet-1a-id"
ssm_public_subnet_1b_id = "/ecs-pro-network/public-subnet-1b-id"
ssm_public_subnet_1c_id = "/ecs-pro-network/public-subnet-1c-id"

# Balancer
load_balancer_internal = false
load_balancer_type     = "application"
