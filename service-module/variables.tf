variable "region" {
  type        = string
  description = "Região onde os recursos do AWS serão provisionados."
}

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

variable "service_health_check" {
  description = "The health check configuration for the service target group."
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

variable "service_listener" {}

variable "service_task_execution_role" {
}

variable "environment_variables" {
  description = "A list of environment variables to set in the container."
}

variable "capabilities" {
  description = "A list of capabilities to add to the container."
  type        = list(string)
}

variable "service_launch_type" {

  description = "The launch type for the service."
  type        = string
}

variable "service_task_count" {
  description = "The number of tasks to run for the service."
  type        = number
}

variable "service_hosts" {}

