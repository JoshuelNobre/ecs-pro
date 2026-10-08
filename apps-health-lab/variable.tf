variable "region" {
  description = "The region where the resources will be deployed."
  type        = string
}

variable "cluster_name" {
  description = "The name of the ECS cluster the services run on."
  type        = string
}

variable "ssm_vpc_id" {
  description = "The SSM parameter name for the VPC ID."
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

variable "ssm_listener" {
  description = "The SSM parameter name for the public load balancer listener ARN."
  type        = string
}

variable "ssm_alb" {
  description = "The SSM parameter name for the public load balancer ARN."
  type        = string
}

variable "ssm_listener_internal" {
  description = "The SSM parameter name for the internal load balancer listener ARN."
  type        = string
}

variable "ssm_alb_internal" {
  description = "The SSM parameter name for the internal load balancer ARN."
  type        = string
}

variable "ssm_service_discovery_namespace" {
  description = "The SSM parameter name for the Cloud Map namespace id."
  type        = string
}

variable "discovery_domain" {
  description = "Domain of the Cloud Map namespace. Services address each other at <service>.<domain>. Internal only: never the address callers from outside use."
  type        = string
}

variable "ingress_domain" {
  description = "Domain callers use to reach the lab from outside. Matched as a host header on the listener rule, so it routes whether or not it resolves in DNS."
  type        = string
}

variable "ssm_service_connect_name" {
  description = "The SSM parameter name for the Service Connect namespace id."
  type        = string
}

variable "ssm_vpc_cidr" {
  description = "The SSM parameter name for the VPC CIDR block."
  type        = string
}
