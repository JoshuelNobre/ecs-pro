resource "aws_appautoscaling_target" "main" {
  max_capacity       = var.task_maximum
  min_capacity       = var.task_minimum
  resource_id        = format("service/%s/%s", var.cluster_name, var.service_name)
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}