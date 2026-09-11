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

# variable "service_launch_type" {

#   description = "The launch type for the service."
#   type        = string
# }

variable "service_launch_type" {
  description = "Configuração dos Launch Types pelos capacity providers disponíveis no cluster"
  type = list(object({
    capacity_provider = string
    weight            = number
  }))
  default = [{
    capacity_provider = "SPOT"
    weight            = 100
  }]
}

variable "service_task_count" {
  description = "The number of tasks to run for the service."
  type        = number
}

variable "service_hosts" {}

variable "scale_type" {
  default = null
}

variable "task_minimum" {
  default = 1
}

variable "task_maximum" {
  default = 10
}

# Autoscaling CPU

variable "scale_out_cpu_threshold" {
  description = "The CPU utilization threshold for scaling out the service."
  type        = number
  default     = 80
}

variable "scale_out_adjustment" {
  description = "The number of tasks to add when scaling out the service."
  type        = number
  default     = 1
}

variable "scale_out_comparison_operator" {
  description = "The comparison operator for scaling out the service."
  type        = string
  default     = "GreaterThanOrEqualToThreshold"
}

variable "scale_out_statistic" {
  description = "The statistic to use for scaling out the service."
  type        = string
  default     = "Average"
}

variable "scale_out_period" {
  description = "The number of evaluation periods for scaling out the service."
  type        = number
  default     = 60
}

variable "scale_out_evaluation_periods" {
  description = "The number of evaluation periods for scaling out the service."
  type        = number
  default     = 2
}

variable "scale_out_cooldown" {
  description = "The cooldown period (in seconds) after scaling out the service."
  type        = number
  default     = 60
}

###
variable "scale_in_cpu_threshold" {
  description = "The CPU utilization threshold for scaling in the service."
  type        = number
  default     = 30
}

variable "scale_in_adjustment" {
  description = "The number of tasks to add when scaling in the service."
  type        = number
  default     = -1
}

variable "scale_in_comparison_operator" {
  description = "The comparison operator for scaling in the service."
  type        = string
  default     = "LessThanOrEqualToThreshold"
}

variable "scale_in_statistic" {
  description = "The statistic to use for scaling in the service."
  type        = string
  default     = "Average"
}

variable "scale_in_period" {
  description = "The number of evaluation periods for scaling in the service."
  type        = number
  default     = 120
}

variable "scale_in_evaluation_periods" {
  description = "The number of evaluation periods for scaling in the service."
  type        = number
  default     = 3
}

variable "scale_in_cooldown" {
  description = "The cooldown period (in seconds) after scaling in the service."
  type        = number
  default     = 120
}

# Tracking CPU
variable "scale_tracking_cpu" {
  description = "The CPU utilization metric to track for scaling the service."
  type        = string
  default     = 80
}

# Tracking request
variable "alb_arn" {
  description = "The ARN of the Application Load Balancer to track for scaling the service."
  type        = string
  default     = null
}

variable "scale_tracking_request" {
  description = "The request count metric to track for scaling the service."
  type        = string
  default     = 0
}
variable "container_image" {
  description = "Fully qualified image the task runs, including the tag. Built and pushed by the pipeline, which owns the ECR repository."
  type        = string
}

variable "efs_volumes" {
  description = "A list of EFS volumes to mount in the container."
  type = list(object({
    volume_name    = string
    file_system_id = string
    root_directory = string
    container_path = string
    read_only      = bool
  }))
  default = []
}