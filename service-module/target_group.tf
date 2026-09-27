resource "aws_lb_target_group" "main" {

  count = var.use_lb ? 1 : 0

  # 32 caracteres é o teto da AWS, e o nome precisa ser único na conta. O nome
  # do serviço vai na frente para dar para reconhecer no console; os 8 dígitos
  # de hash cobrem serviços homônimos em clusters diferentes e o caso de dois
  # nomes longos truncarem no mesmo ponto. 23 + 1 + 8 = 32
  name = format(
    "%s-%s",
    trimsuffix(substr(var.service_name, 0, 23), "-"),
    substr(sha256(format("%s%s", var.service_name, var.cluster_name)), 0, 8)
  )

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