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