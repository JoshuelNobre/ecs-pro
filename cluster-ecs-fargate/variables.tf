variable "project_name" {
  description = "The name of the project"
}

variable "region" {
  description = "The region where the project will be deployed"
}

variable "ssm_vpc_id" {
  description = "The SSM parameter name for the VPC ID"
}

variable "ssm_vpc_cidr" {
  description = "The SSM parameter name for the VPC CIDR block"
}

variable "ssm_public_subnet_1a_id" {
  description = "The SSM parameter name for the public subnet 1a ID"
}

variable "ssm_public_subnet_1b_id" {
  description = "The SSM parameter name for the public subnet 1b ID"
}

variable "ssm_public_subnet_1c_id" {
  description = "The SSM parameter name for the public subnet 1c ID"
}

# Balancer

variable "load_balancer_internal" {}

variable "load_balancer_type" {
  description = "The load balancer type: application or network"
  type        = string
  default     = "application"
}

variable "load_balancer_cross_zone_enabled" {
  description = "Whether to distribute traffic across availability zones. Applies to network load balancers only: application load balancers are always cross-zone and cannot be changed."
  type        = bool
  default     = true
}

# ECS Cluster

variable "capacity_providers" {
  type    = list(string)
  default = ["FARGATE", "FARGATE_SPOT"]
}
