variable "name_prefix" {
  description = "Prefix used to name the ECR repositories."
  type        = string
}

variable "service_names" {
  description = "Names of the ECS services that require an ECR repository."
  type        = set(string)
}

variable "image_retention_count" {
  description = "Number of images kept by each repository lifecycle policy."
  type        = number
}

variable "tags" {
  description = "Common tags applied to the ECR repositories."
  type        = map(string)
  default     = {}
}
