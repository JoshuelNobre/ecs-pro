resource "aws_security_group" "main" {
  name        = format("%s", var.project_name)
  description = "Security group for the ECS cluster"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  egress {
    description = "Allow all outbound traffic (required by the ECS agent)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_all_from_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [data.aws_ssm_parameter.vpc_cidr.value]
  security_group_id = aws_security_group.main.id
  description       = "Allow all traffic from the VPC"
}