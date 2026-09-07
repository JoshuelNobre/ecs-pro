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
