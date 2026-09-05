project_name = "cluster-ecs-ec2"
region       = "us-east-1"

# SSM VPC Parameters
ssm_vpc_id               = "/ecs-pro-network/vpc-id"
ssm_vpc_cidr             = "/ecs-pro-network/vpc-cidr"
ssm_public_subnet_1a_id  = "/ecs-pro-network/public-subnet-1a-id"
ssm_public_subnet_1b_id  = "/ecs-pro-network/public-subnet-1b-id"
ssm_public_subnet_1c_id  = "/ecs-pro-network/public-subnet-1c-id"
ssm_private_subnet_1a_id = "/ecs-pro-network/private-subnet-1a-id"
ssm_private_subnet_1b_id = "/ecs-pro-network/private-subnet-1b-id"
ssm_private_subnet_1c_id = "/ecs-pro-network/private-subnet-1c-id"

# Balancer
load_balancer_internal = false
load_balancer_type     = "application"

# ECS General
node_ami           = "ami-0f60dc6bf6dbca3e9"
node_instance_type = "t3.medium"
node_volume_size   = 20
node_volume_type   = "gp3"