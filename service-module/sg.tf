resource "aws_security_group" "main" {
  name        = format("%s-%s-sg", var.cluster_name, var.service_name)
  description = "Security group for the ${var.service_name} service in the ${var.cluster_name} cluster."
  vpc_id      = var.vpc_id

  # a faixa inteira porque os serviços se chamam em portas variadas — a
  # health-api na 8080 alcança os gRPC na 30000 — mas só de dentro da VPC.
  # As tasks vivem em subnet privada, então nada roteia de fora de qualquer jeito
  ingress {
    description = "Service to service traffic inside the VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # o balanceador entra pela porta do serviço
  ingress {
    description = "Load balancer to the service port"
    from_port   = var.service_port
    to_port     = var.service_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # saída aberta: a task puxa imagem do registry, manda log e lê parâmetros,
  # tudo em endpoints públicos da AWS
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
