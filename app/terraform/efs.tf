resource "aws_efs_file_system" "main" {
  creation_token   = format("%s-efs", var.service_name)
  performance_mode = "generalPurpose"

  encrypted = true

  tags = {
    Name = format("%s-efs", var.service_name)
  }
}

resource "aws_security_group" "efs" {
  name        = format("%s-efs", var.service_name)
  description = "Security group for EFS"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress {
    description = "NFS from the ECS tasks"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_ssm_parameter.vpc_cidr.value]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_ssm_parameter.vpc_cidr.value]
  }
}

resource "aws_efs_mount_target" "mount_1a" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = data.aws_ssm_parameter.private_subnet_1a.value
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "mount_1b" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = data.aws_ssm_parameter.private_subnet_1b.value
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "mount_1c" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = data.aws_ssm_parameter.private_subnet_1c.value
  security_groups = [aws_security_group.efs.id]
}
