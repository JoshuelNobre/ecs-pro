output "load_balancer_dns" {
  value = aws_lb.main.dns_name
}

output "lb_ssm_arn" {
  value = aws_ssm_parameter.lb_arn.id
}

output "lb_listener_ssm_arn" {
  value = aws_ssm_parameter.lb_listener_arn.id
}