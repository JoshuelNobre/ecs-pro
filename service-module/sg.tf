resource "aws_security_group" "main" {
  name        = format("%s-%s-sg", var.cluster_name, var.service_name)
  description = "Security group for the ${var.service_name} service in the ${var.cluster_name} cluster."
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.service_port
    to_port     = var.service_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}