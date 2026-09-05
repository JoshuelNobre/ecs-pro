resource "aws_launch_template" "spot" {
  name_prefix   = format("%s-spot-", var.project_name)
  image_id      = var.node_ami
  instance_type = var.node_instance_type

  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
      max_price                      = var.spot_max_price
      spot_instance_type             = "one-time"
    }
  }

  vpc_security_group_ids = [aws_security_group.main.id]

  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.node_volume_size
      volume_type           = var.node_volume_type
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = format("%s-spot", var.project_name)
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance.name
  }

  user_data = base64encode(templatefile("${path.module}/templates/user-data.tpl", {
    CLUSTER_NAME = aws_ecs_cluster.main.name
  }))
}