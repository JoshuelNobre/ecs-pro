region       = "us-east-1"
cluster_name = "jonoma-it"

ssm_vpc_id            = "/jonoma-it/vpc-id"
ssm_private_subnet_1a = "/jonoma-it/private-subnet-1a-id"
ssm_private_subnet_1b = "/jonoma-it/private-subnet-1b-id"
ssm_private_subnet_1c = "/jonoma-it/private-subnet-1c-id"

ssm_listener = "/jonoma-it/lb-listener-arn"
ssm_alb      = "/jonoma-it/lb-arn"

ssm_listener_internal = "/jonoma-it/lb-internal-listener-arn"
ssm_alb_internal      = "/jonoma-it/lb-internal-arn"

ssm_service_discovery_namespace = "/jonoma-it/cloudmap/namespace"

# como os serviços se acham entre si: namespace do Cloud Map, definido em
# cluster-ecs-fargate/service-discovery.tf. Não é endereço de entrada
discovery_domain = "jonoma-it.local.com"

# como se chega ao lab de fora, casado como host header na regra do listener
ingress_domain = "jonoma-it.com"

# o namespace do Service Connect é separado do Cloud Map: outro domínio, outro
# mecanismo. O "dns" guarda o nome, o "namespace" guarda o id ns-...
ssm_service_connect_name = "/jonoma-it/service-connect/dns"
ssm_service_connect_arn  = "/jonoma-it/service-connect/namespace"