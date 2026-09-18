resource "aws_ssm_parameter" "lb_arn" {
  name  = format("/%s/lb-arn", var.project_name)
  type  = "String"
  value = aws_lb.main.arn
}

resource "aws_ssm_parameter" "lb_listener_arn" {
  name  = format("/%s/lb-listener-arn", var.project_name)
  type  = "String"
  value = aws_lb_listener.http.arn
}

resource "aws_ssm_parameter" "lb_internal_arn" {
  name  = format("/%s/lb-internal-arn", var.project_name)
  type  = "String"
  value = aws_lb.internal.arn
}

resource "aws_ssm_parameter" "lb_internal_listener_arn" {
  name  = format("/%s/lb-internal-listener-arn", var.project_name)
  type  = "String"
  value = aws_lb_listener.http_internal.arn
}