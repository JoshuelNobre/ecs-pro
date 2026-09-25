variable "region" {
  description = "The region where the resources will be deployed."
  type        = string
}

variable "cluster_name" {
  description = "The name of the ECS cluster the service runs on."
  type        = string
}

variable "service_name" {
  description = "The name of the ECS service."
  type        = string
}

variable "service_hosts" {
  description = "Host headers the listener rule matches to route to this service."
  type        = list(string)
}

variable "ssm_listener" {
  description = "The SSM parameter name for the load balancer listener ARN."
  type        = string
}

variable "ssm_alb_arn" {
  description = "The SSM parameter name for the load balancer ARN."
  type        = string
}

variable "ssm_vpc_id" {
  description = "The SSM parameter name for the VPC ID."
  type        = string
}

variable "ssm_vpc_cidr" {
  description = "The SSM parameter name for the VPC CIDR block."
  type        = string
}

variable "ssm_private_subnet_1a" {
  description = "The SSM parameter name for the private subnet in 1a."
  type        = string
}

variable "ssm_private_subnet_1b" {
  description = "The SSM parameter name for the private subnet in 1b."
  type        = string
}

variable "ssm_private_subnet_1c" {
  description = "The SSM parameter name for the private subnet in 1c."
  type        = string
}

variable "ssm_service_discovery_namespace" {
  description = "The SSM parameter name for the Cloud Map namespace id."
  type        = string
}
