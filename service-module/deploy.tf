resource "null_resource" "deploy_ecs" {
  count = var.deployment_controller == "ECS" ? 1 : 0

  triggers = {
    task_definition = aws_ecs_task_definition.main.revision
  }

  depends_on = [
    aws_ecs_service.main,
    aws_ecs_task_definition.main
  ]

  provisioner "local-exec" {
    command = <<EOT
      aws ecs update-service \
        --cluster ${var.cluster_name} \
        --service ${var.service_name} \
        --task-definition ${aws_ecs_task_definition.main.arn}
    EOT
  }
}