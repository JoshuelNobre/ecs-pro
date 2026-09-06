resource "aws_cloudwatch_log_group" "main" {
  name              = format("/ecs/%s-%s", var.cluster_name, var.service_name)
  retention_in_days = 1
}