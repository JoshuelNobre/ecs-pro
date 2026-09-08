variable "region" {
  description = "The region where the resources will be deployed."
  type        = string
}

variable "cluster_name" {
  description = "The name of the ECS cluster."
  type        = string
}

variable "service_name" {
  description = "The name of the ECS service."
  type        = string
}

variable "service_port" {
  description = "The port on which the ECS service will listen."
  type        = number
}

variable "service_cpu" {
  description = "The amount of CPU units to allocate for the ECS service."
  type        = number
}

variable "service_memory" {
  description = "The amount of memory (in MiB) to allocate for the ECS service."
  type        = number
}

variable "service_health_check" {
  description = "The health check configuration for the ECS service target group."
  type = object({
    path                = string
    interval            = number
    timeout             = number
    healthy_threshold   = number
    unhealthy_threshold = number
    matcher             = string
    port                = number
  })
}

variable "ssm_listener" {
  description = "The listener configuration for the ECS service."
  type        = any
}

variable "ssm_vpc_id" {
  description = "The ID of the VPC where the ECS service will be deployed."
  type        = string
}

variable "ssm_private_subnet_1a" {
  description = "The ID of the private subnet in availability zone 1a."
  type        = string
}

variable "ssm_private_subnet_1b" {
  description = "The ID of the private subnet in availability zone 1b."
  type        = string
}

variable "ssm_private_subnet_1c" {
  description = "The ID of the private subnet in availability zone 1c."
  type        = string
}

variable "environment_variables" {
  description = "A list of environment variables to set in the container."
}

variable "capabilities" {
  description = "A list of capabilities to add to the container."
}

variable "service_launch_type" {

}

variable "service_task_count" {
  description = "The number of tasks to run for the service."
  type        = number
}

variable "service_hosts" {}

variable "scale_type" {}

variable "task_minimum" {}

variable "task_maximum" {}

# Autoscaling cpu

variable "scale_out_cpu_threshold" {
  description = "The CPU utilization threshold for scaling out the service."
  type        = number
}

variable "scale_out_adjustment" {
  description = "The number of tasks to add when scaling out the service."
  type        = number
}

variable "scale_out_comparison_operator" {
  description = "The comparison operator for scaling out the service."
  type        = string
}

variable "scale_out_statistic" {
  description = "The statistic to use for scaling out the service."
  type        = string
}

variable "scale_out_period" {
  description = "The number of evaluation periods for scaling out the service."
  type        = number
}

variable "scale_out_evaluation_periods" {
  description = "The number of evaluation periods for scaling out the service."
  type        = number
}

variable "scale_out_cooldown" {
  description = "The cooldown period (in seconds) after scaling out the service."
  type        = number
}

variable "scale_in_cpu_threshold" {
  description = "The CPU utilization threshold for scaling in the service."
  type        = number
}

variable "scale_in_adjustment" {
  description = "The number of tasks to add when scaling in the service."
  type        = number
}

variable "scale_in_comparison_operator" {
  description = "The comparison operator for scaling in the service."
  type        = string
}

variable "scale_in_statistic" {
  description = "The statistic to use for scaling in the service."
  type        = string
}

variable "scale_in_period" {
  description = "The number of evaluation periods for scaling in the service."
  type        = number
}

variable "scale_in_evaluation_periods" {
  description = "The number of evaluation periods for scaling in the service."
  type        = number
}

variable "scale_in_cooldown" {
  description = "The cooldown period (in seconds) after scaling in the service."
  type        = number
}