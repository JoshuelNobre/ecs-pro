resource "aws_appautoscaling_target" "main" {
  max_capacity = var.task_maximum
  min_capacity = var.task_minimum
  # referencia o serviço em vez da variável: as políticas de tracking exigem
  # que o target group já esteja anexado, e é esta aresta que garante a ordem
  resource_id        = format("service/%s/%s", var.cluster_name, aws_ecs_service.main.name)
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}