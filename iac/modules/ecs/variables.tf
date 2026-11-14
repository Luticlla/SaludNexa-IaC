variable "name_prefix" {
  description = "Prefix used to name the ECS cluster, log groups, and task definitions."
  type        = string
}

variable "services" {
  description = "ECS services keyed by name, including container port, ALB route, Fargate size, and autoscaling bounds."
  type = map(object({
    port   = number
    route  = string
    cpu    = number
    memory = number
    min    = number
    max    = number
  }))
}

variable "log_retention_days" {
  description = "Retention in days for each service CloudWatch log group."
  type        = number
}

variable "aws_region" {
  description = "AWS region used by the awslogs driver."
  type        = string
}

variable "container_image" {
  description = "Container image used by every task definition."
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the shared ECS task execution role."
  type        = string
}

variable "task_role_arns" {
  description = "ARNs of the per-service ECS task roles keyed by service name."
  type        = map(string)
}

variable "app_subnet_ids" {
  description = "Private application subnet IDs where ECS tasks run."
  type        = list(string)
}

variable "task_security_group_id" {
  description = "Security group ID attached to ECS tasks."
  type        = string
}

variable "target_group_arns" {
  description = "Target group ARNs keyed by service name."
  type        = map(string)
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum healthy percent during ECS service deployments."
  type        = number
}

variable "deployment_maximum_percent" {
  description = "Maximum percent of tasks during ECS service deployments."
  type        = number
}

variable "cpu_target_value" {
  description = "Target average CPU utilization percentage for ECS service autoscaling."
  type        = number
}

variable "scale_out_cooldown" {
  description = "Scale-out cooldown in seconds for the ECS autoscaling policy."
  type        = number
}

variable "scale_in_cooldown" {
  description = "Scale-in cooldown in seconds for the ECS autoscaling policy."
  type        = number
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization percentage that triggers the sustained-high CPU alarm."
  type        = number
}

variable "cpu_alarm_evaluation_periods" {
  description = "Number of 60-second periods the CPU alarm must breach before firing."
  type        = number
}

variable "alarm_actions" {
  description = "Optional ARNs notified by the CloudWatch CPU alarms."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags applied to ECS and CloudWatch resources."
  type        = map(string)
  default     = {}
}
