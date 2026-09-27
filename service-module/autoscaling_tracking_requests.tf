resource "aws_appautoscaling_policy" "target_tracking_requests" {

  # exige balanceador: a métrica é de requisições por target do ALB, e o
  # resource_label precisa dos dois arn_suffix
  count = var.scale_type == "requests_tracking" && var.use_lb && var.alb_arn != null ? 1 : 0

  name = format("%s-%s-requests-tracking", var.cluster_name, var.service_name)

  resource_id        = aws_appautoscaling_target.main.resource_id
  service_namespace  = aws_appautoscaling_target.main.service_namespace
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension

  policy_type = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = var.scale_tracking_request
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${data.aws_alb.main[0].arn_suffix}/${aws_lb_target_group.main[0].arn_suffix}"
    }

  }

}









