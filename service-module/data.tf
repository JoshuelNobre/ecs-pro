data "aws_alb" "main" {
  count = var.alb_arn != null ? 1 : 0

  arn = var.alb_arn
}
