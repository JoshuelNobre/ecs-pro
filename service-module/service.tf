resource "aws_ecs_service" "main" {
  name            = var.service_name
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.service_task_count
  #   launch_type     = var.service_launch_type

  #   capacity_provider_strategy {
  #     capacity_provider = var.service_launch_type
  #     weight            = 100
  #   }

  dynamic "capacity_provider_strategy" {
    for_each = var.service_launch_type

    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
    }
  }

  dynamic "service_connect_configuration" {
    for_each = var.use_service_connect ? [var.service_connect_name] : []

    content {
      enabled   = var.use_service_connect
      namespace = var.service_connect_name

      service {
        port_name      = var.service_name
        discovery_name = var.service_name
        client_alias {
          port     = var.service_port
          dns_name = format("%s.%s", var.service_name, var.service_connect_name)
        }
      }
    }
  }

  # serviço interno (gRPC entre tasks, por exemplo) não precisa de balanceador:
  # quem descobre o endereço é o Cloud Map, e o tráfego vai direto ao IP da task
  dynamic "load_balancer" {
    for_each = aws_lb_target_group.main

    content {
      target_group_arn = load_balancer.value.arn
      container_name   = var.service_name
      container_port   = var.service_port
    }
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  force_new_deployment               = true

  depends_on = [aws_alb_listener_rule.main]

  dynamic "service_registries" {
    for_each = var.service_discovery_namespace != null ? [var.service_name] : []

    content {
      registry_arn   = aws_service_discovery_service.main[0].arn
      container_name = service_registries.value
    }
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.service_launch_type == "EC2" ? [1] : []
    content {
      type  = "spread"
      field = "attribute:ecs.availability-zone"
    }
  }

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.main.id]
    assign_public_ip = false
  }

  #   platform_version = "LATEST"

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}