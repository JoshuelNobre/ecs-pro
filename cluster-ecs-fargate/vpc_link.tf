resource "aws_security_group" "vpc_link" {
  name        = format("%s-vpc-link", var.project_name)
  description = "Security group for the VPC link"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  egress {
    description = "Allow all outbound traffic to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_ssm_parameter.vpc_cidr.value]
  }

}

resource "aws_security_group_rule" "vpc_link_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vpc_link.id
  description       = "Allow HTTP traffic from anywhere"
}

resource "aws_security_group_rule" "vpc_link_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vpc_link.id
  description       = "Allow HTTPS traffic from anywhere"
}

resource "aws_lb" "vpc_link" {
  name               = trimsuffix(substr(format("%s-vpc-link", var.project_name), 0, 32), "-")
  internal           = true
  load_balancer_type = "network"
  security_groups    = [aws_security_group.vpc_link.id]
  subnets = [
    data.aws_ssm_parameter.private_subnet_1a_id.value,
    data.aws_ssm_parameter.private_subnet_1b_id.value,
    data.aws_ssm_parameter.private_subnet_1c_id.value,
  ]
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = false

  tags = {
    Name = format("%s-ingress", var.project_name)
  }
}

resource "aws_lb_target_group" "vpc_link" {
  name        = trimsuffix(substr(format("%s-vpc-link", var.project_name), 0, 32), "-")
  port        = 80
  protocol    = "TCP"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  target_type = "alb"

  target_health_state {
    enable_unhealthy_connection_termination = false
  }

  tags = {
    Name = format("%s-ingress", var.project_name)
  }
}

resource "aws_lb_listener" "vpc_link" {
  load_balancer_arn = aws_lb.vpc_link.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vpc_link.arn
  }
}

resource "aws_lb_target_group_attachment" "internal_lb" {
  target_group_arn = aws_lb_target_group.vpc_link.arn
  target_id        = aws_lb.internal.arn
  port             = 80

  # o alvo é o ALB, não o listener, então o Terraform não liga os dois sozinho.
  # A AWS exige que o ALB tenha listener na porta registrada, e recusa remover
  # esse listener enquanto o ALB for alvo de alguém — sem esta aresta o destroy
  # tenta apagar o listener primeiro e falha com ResourceInUse
  depends_on = [aws_lb_listener.http_internal]
}

resource "aws_api_gateway_vpc_link" "vpc_link" {
  name        = format("%s-vpc-link", var.project_name)
  target_arns = [aws_lb.vpc_link.arn]
}