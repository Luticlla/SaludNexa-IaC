variable "name_prefix" {
  description = "Prefix used to name the ALB, target groups, listener, and rules."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the target groups are created."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used by the ALB. At least two subnets in different AZs are required."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "The ALB requires at least two public subnets in different availability zones."
  }
}

variable "security_group_id" {
  description = "Security group ID attached to the ALB."
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS. If empty, an HTTP listener on port 80 is created for testing."
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

variable "health_check_path" {
  description = "Path used by the target group health checks."
  type        = string
}

variable "health_check_matcher" {
  description = "HTTP status codes considered healthy by the target groups."
  type        = string
}

variable "alb_5xx_threshold_percent" {
  description = "ALB 5xx error rate percentage that triggers the alarm."
  type        = number
}

variable "alb_5xx_evaluation_periods" {
  description = "Number of 300-second periods the ALB 5xx alarm must breach before firing."
  type        = number
}

variable "alarm_actions" {
  description = "Optional ARNs notified by the ALB 5xx alarm."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags applied to ALB resources."
  type        = map(string)
  default     = {}
}
