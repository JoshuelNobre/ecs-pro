variable "service_name" {
  description = "The name of the service."
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster where the service will be deployed."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the service will be deployed."
  type        = string
}

variable "private_subnets" {
  description = "A list of private subnet IDs where the service will be deployed."
  type        = list(string)
}

variable "service_port" {
  description = "The port on which the service will listen."
  type        = number
}

variable "service_cpu" {
  description = "The amount of CPU units to allocate for the service."
  type        = number
}

variable "service_memory" {
  description = "The amount of memory (in MiB) to allocate for the service."
  type        = number
}

variable "service_listener" {}

variable "service_task_execution_role" {
}