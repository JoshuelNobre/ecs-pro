resource "aws_autoscaling_group" "on_demand" {
  name             = format("%s-on-demand", var.project_name)
  max_size         = var.cluster_on_demand_max_size
  min_size         = var.cluster_on_demand_min_size
  desired_capacity = var.cluster_on_demand_desired_capacity
  vpc_zone_identifier = [
    data.aws_ssm_parameter.private_subnet_1a_id.value,
    data.aws_ssm_parameter.private_subnet_1b_id.value,
    data.aws_ssm_parameter.private_subnet_1c_id.value
  ]
  launch_template {
    id      = aws_launch_template.on_demand.id
    version = aws_launch_template.on_demand.latest_version
  }

  tag {
    key                 = "Name"
    value               = format("%s-on-demand", var.project_name)
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "on_demand" {
  name = format("%s-on-demand", var.project_name)

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.on_demand.arn
    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 80
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 10
    }
  }
}