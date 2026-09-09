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


variable "ssm_private_subnet_1a_id" {
  description = "The SSM parameter name for the private subnet 1a ID"
}

variable "ssm_private_subnet_1b_id" {
  description = "The SSM parameter name for the private subnet 1b ID"
}

variable "ssm_private_subnet_1c_id" {
  description = "The SSM parameter name for the private subnet 1c ID"
}

# Balancer

variable "load_balancer_internal" {}

variable "load_balancer_type" {}

# ECS General

variable "node_ami" {
  description = "The AMI ID for the ECS nodes"
}

variable "node_instance_type" {
  description = "The instance type for the ECS nodes"
}

variable "node_volume_size" {
  description = "The size of the EBS volume for the ECS nodes"
}

variable "node_volume_type" {
  description = "The type of the EBS volume for the ECS nodes"
}

variable "cluster_on_demand_min_size" {
  description = "The minimum size of the on-demand ECS cluster"
}

variable "cluster_on_demand_max_size" {
  description = "The maximum size of the on-demand ECS cluster"
}

variable "cluster_on_demand_desired_capacity" {
  description = "The desired capacity of the on-demand ECS cluster"
}

variable "cluster_spot_min_size" {
  description = "The minimum size of the spot ECS cluster"
}

variable "cluster_spot_max_size" {
  description = "The maximum size of the spot ECS cluster"
}

variable "cluster_spot_desired_capacity" {
  description = "The desired capacity of the spot ECS cluster"
}

variable "spot_max_price" {
  description = "The maximum price for spot instances"
}

variable "capacity_providers" {
  type    = list(string)
  default = ["FARGATE", "FARGATE_SPOT"]
}