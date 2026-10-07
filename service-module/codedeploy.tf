resource "aws_codedeploy_app" "main" {

  count            = var.deployment_controller == "CODE_DEPLOY" ? 1 : 0
  name             = format("%s-%s", var.cluster_name, var.service_name)
  compute_platform = "ECS"

}

resource "aws_codedeploy_deployment_group" "main" {

  count = var.deployment_controller == "CODE_DEPLOY" ? 1 : 0

  app_name              = aws_codedeploy_app.main[count.index].name
  deployment_group_name = format("%s-%s", var.cluster_name, var.service_name)
  service_role_arn      = aws_iam_role.codedeploy_role[count.index].arn

  deployment_config_name = var.codedeploy_strategy

  # pelo atributo do serviço, não pela variável: o CodeDeploy lê o serviço na
  # criação do grupo, e é esta referência que impede o Terraform de criar os
  # dois em paralelo
  ecs_service {
    cluster_name = var.cluster_name
    service_name = aws_ecs_service.main.name
  }

  deployment_style {
    deployment_option = var.codedeployment_option
    deployment_type   = var.codedeployment_type
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                           = var.codedeploy_terminate_action
      termination_wait_time_in_minutes = var.codedeploy_wait_time
    }

    deployment_ready_option {
      action_on_timeout = var.codedeploy_timeout_action
    }
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.service_listener]
      }

      target_group {
        name = aws_lb_target_group.blue[count.index].name
      }
      target_group {
        name = aws_lb_target_group.green[count.index].name
      }
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}