variable "name_prefix" {
  description = "Prefix used to name the IAM roles."
  type        = string
}

variable "service_names" {
  description = "Names of the ECS services that require a dedicated task role."
  type        = set(string)
}

variable "tags" {
  description = "Common tags applied to the IAM roles."
  type        = map(string)
  default     = {}
}
