resource "aws_autoscaling_group" "spot" {
  name             = format("%s-spot", var.project_name)
  max_size         = var.cluster_spot_max_size
  min_size         = var.cluster_spot_min_size
  desired_capacity = var.cluster_spot_desired_capacity
  vpc_zone_identifier = [
    data.aws_ssm_parameter.private_subnet_1a_id.value,
    data.aws_ssm_parameter.private_subnet_1b_id.value,
    data.aws_ssm_parameter.private_subnet_1c_id.value
  ]
  launch_template {
    id      = aws_launch_template.spot.id
    version = aws_launch_template.spot.latest_version
  }

  tag {
    key                 = "Name"
    value               = format("%s-spot", var.project_name)
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "spot" {
  name = format("%s-spot", var.project_name)

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.spot.arn
    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 80
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 10
    }
  }
}