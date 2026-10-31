variable "aws_region" {
  description = "AWS region where the SaludNexa core is deployed."
  type        = string
  default     = "sa-east-1"
}

variable "project" {
  description = "Project name used as a prefix and in common tags."
  type        = string
  default     = "SaludNexa"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Primary AZ for compute and the secondary AZ required by the ALB."
  type = object({
    primary   = string
    secondary = string
  })
  default = {
    primary   = "sa-east-1a"
    secondary = "sa-east-1b"
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the two public subnets. Subnet B exists only to satisfy the ALB multi-AZ requirement."
  type = object({
    a = string
    b = string
  })
  default = {
    a = "10.0.1.0/24"
    b = "10.0.2.0/24"
  }
}

variable "app_subnet_cidr" {
  description = "CIDR block for the private application subnet in the primary AZ."
  type        = string
  default     = "10.0.11.0/24"
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
  default = {
    citas-svc = {
      port   = 80
      route  = "/api/citas/*"
      cpu    = 512
      memory = 1024
      min    = 1
      max    = 6
    }
    usuarios-svc = {
      port   = 80
      route  = "/api/usuarios/*"
      cpu    = 512
      memory = 1024
      min    = 1
      max    = 4
    }
    pagos-svc = {
      port   = 80
      route  = "/api/pagos/*"
      cpu    = 512
      memory = 1024
      min    = 1
      max    = 4
    }
    teleconsulta-svc = {
      port   = 80
      route  = "/api/teleconsulta/*"
      cpu    = 512
      memory = 1024
      min    = 1
      max    = 4
    }
  }

  validation {
    condition = alltrue([
      for service in values(var.services) :
      service.port >= 1 &&
      service.port <= 65535 &&
      service.cpu > 0 &&
      service.memory > 0 &&
      service.min >= 1 &&
      service.max >= service.min
    ])
    error_message = "Each service must define a valid port, positive CPU and memory, and 1 <= min <= max."
  }

  validation {
    condition     = length(distinct([for service in values(var.services) : service.route])) == length(var.services)
    error_message = "Service routes must be unique."
  }
}

variable "container_image" {
  description = "Placeholder image used by every ECS task definition until backend images are published."
  type        = string
  default     = "nginx:1.27-alpine"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener. If empty, an HTTP listener on port 80 is created for testing only."
  type        = string
  default     = ""
}

variable "health_check_path" {
  description = "Path used by the ALB target group health checks."
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "HTTP status codes considered healthy by the ALB target groups."
  type        = string
  default     = "200-399"
}

variable "log_retention_days" {
  description = "Retention in days for each service CloudWatch log group."
  type        = number
  default     = 14
}

variable "ecr_image_retention_count" {
  description = "Number of images kept by each ECR repository lifecycle policy."
  type        = number
  default     = 10
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum healthy percent during ECS service deployments."
  type        = number
  default     = 100
}

variable "deployment_maximum_percent" {
  description = "Maximum percent of tasks during ECS service deployments."
  type        = number
  default     = 200
}

variable "cpu_target_value" {
  description = "Target average CPU utilization percentage for ECS service autoscaling."
  type        = number
  default     = 60
}

variable "scale_out_cooldown" {
  description = "Scale-out cooldown in seconds for the ECS autoscaling policy."
  type        = number
  default     = 60
}

variable "scale_in_cooldown" {
  description = "Scale-in cooldown in seconds for the ECS autoscaling policy."
  type        = number
  default     = 300
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization percentage that triggers the sustained-high CPU alarm."
  type        = number
  default     = 80
}

variable "cpu_alarm_evaluation_periods" {
  description = "Number of 60-second periods the CPU alarm must breach before firing."
  type        = number
  default     = 5
}

variable "alb_5xx_threshold_percent" {
  description = "ALB 5xx error rate percentage that triggers the alarm."
  type        = number
  default     = 0.1
}

variable "alb_5xx_evaluation_periods" {
  description = "Number of 300-second periods the ALB 5xx alarm must breach before firing."
  type        = number
  default     = 2
}

variable "alarm_actions" {
  description = "Optional ARNs notified by CloudWatch alarms. SNS is outside this scope, so the default is empty."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags merged into the common tag set."
  type        = map(string)
  default     = {}
}
