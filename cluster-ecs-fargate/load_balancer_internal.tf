resource "aws_security_group" "lb_internal" {
  name        = format("%s-loadbalancer-internal", var.project_name)
  description = "Security group for the load balancer"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  egress {
    description = "Allow all outbound traffic to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_ssm_parameter.vpc_cidr.value]
  }
}

resource "aws_security_group_rule" "lb_internal_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_internal.id
  description       = "Allow HTTP traffic from anywhere"
}

resource "aws_security_group_rule" "lb_internal_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_internal.id
  description       = "Allow HTTPS traffic from anywhere"
}

resource "aws_lb" "internal" {
  # o limite do ELB é 32 caracteres. O trimsuffix cobre o caso de o corte cair
  # logo depois de um hífen, que a AWS também recusa no fim do nome
  name               = trimsuffix(substr(format("%s-internal-ingress", var.project_name), 0, 32), "-")
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_internal.id]
  subnets = [
    data.aws_ssm_parameter.private_subnet_1a_id.value,
    data.aws_ssm_parameter.private_subnet_1b_id.value,
    data.aws_ssm_parameter.private_subnet_1c_id.value,
  ]
  enable_deletion_protection = false

  # Application load balancers are always cross-zone, so the setting only
  # carries a value for network load balancers.
  enable_cross_zone_load_balancing = var.load_balancer_type == "network" ? var.load_balancer_cross_zone_enabled : true

  tags = {
    Name = format("%s-ingress", var.project_name)
  }
}

resource "aws_lb_listener" "http_internal" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found (Internal Load Balancer)"
      status_code  = "404"
    }
  }
}