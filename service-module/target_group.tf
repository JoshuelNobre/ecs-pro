resource "aws_lb_target_group" "main" {

  name = substr(format("%s%s", var.cluster_name, var.service_name), 0, 32)

  port        = var.service_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    healthy_threshold   = lookup(var.service_health_check, "healthy_threshold", "3")
    interval            = lookup(var.service_health_check, "interval", "30")
    matcher             = lookup(var.service_health_check, "matcher", "200-299")
    path                = lookup(var.service_health_check, "path", "/")
    port                = lookup(var.service_health_check, "port", var.service_port)
    timeout             = lookup(var.service_health_check, "timeout", "5")
    unhealthy_threshold = lookup(var.service_health_check, "unhealthy_threshold", "3")
  }

  # o target group fica preso ao listener rule e ao ECS service enquanto
  # existir, então o novo precisa nascer antes de o antigo ser removido
  lifecycle {
    create_before_destroy = true
  }

}