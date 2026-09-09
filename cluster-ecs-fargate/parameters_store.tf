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