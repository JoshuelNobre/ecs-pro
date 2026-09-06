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