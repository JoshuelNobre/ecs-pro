resource "aws_alb_listener_rule" "main" {

  count = var.use_lb ? 1 : 0

  listener_arn = var.service_listener

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }

  condition {
    host_header {
      values = var.service_hosts
    }
  }
}