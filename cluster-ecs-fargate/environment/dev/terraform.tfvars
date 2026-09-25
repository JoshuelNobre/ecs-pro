project_name = "jonoma-it"
region       = "us-east-1"

# SSM VPC Parameters
ssm_vpc_id               = "/jonoma-it/vpc-id"
ssm_vpc_cidr             = "/jonoma-it/vpc-cidr"
ssm_public_subnet_1a_id  = "/jonoma-it/public-subnet-1a-id"
ssm_public_subnet_1b_id  = "/jonoma-it/public-subnet-1b-id"
ssm_public_subnet_1c_id  = "/jonoma-it/public-subnet-1c-id"
ssm_private_subnet_1a_id = "/jonoma-it/private-subnet-1a-id"
ssm_private_subnet_1b_id = "/jonoma-it/private-subnet-1b-id"
ssm_private_subnet_1c_id = "/jonoma-it/private-subnet-1c-id"

# Balancer
load_balancer_internal = false
load_balancer_type     = "application"
