region       = "us-east-1"
cluster_name = "jonoma-it"
service_name = "pudim"

ssm_listener = "/jonoma-it/lb-listener-arn"
ssm_alb_arn  = "/jonoma-it/lb-arn"

ssm_vpc_id            = "/jonoma-it/vpc-id"
ssm_vpc_cidr          = "/jonoma-it/vpc-cidr"
ssm_private_subnet_1a = "/jonoma-it/private-subnet-1a-id"
ssm_private_subnet_1b = "/jonoma-it/private-subnet-1b-id"
ssm_private_subnet_1c = "/jonoma-it/private-subnet-1c-id"

ssm_service_discovery_namespace = "/jonoma-it/cloudmap/namespace"

service_hosts = [
  "pudim.jonoma-it.com"
]
