resource "aws_security_group" "lb" {
  name        = format("%s-loadbalancer", var.project_name)
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

resource "aws_security_group_rule" "lb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
  description       = "Allow HTTP traffic from anywhere"
}

resource "aws_security_group_rule" "lb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
  description       = "Allow HTTPS traffic from anywhere"
}

resource "aws_lb" "main" {
  name               = format("%s-ingress", var.project_name)
  internal           = var.load_balancer_internal
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.lb.id]
  subnets = [
    data.aws_ssm_parameter.public_subnet_1a_id.value,
    data.aws_ssm_parameter.public_subnet_1b_id.value,
    data.aws_ssm_parameter.public_subnet_1c_id.value,
  ]
  enable_deletion_protection = false

  # Application load balancers are always cross-zone, so the setting only
  # carries a value for network load balancers.
  enable_cross_zone_load_balancing = var.load_balancer_type == "network" ? var.load_balancer_cross_zone_enabled : true

  tags = {
    Name = format("%s-ingress", var.project_name)
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = "404"
    }
  }
}