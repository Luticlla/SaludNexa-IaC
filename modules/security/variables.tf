variable "name_prefix" {
  description = "Prefix used to name the security groups."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the security groups are created."
  type        = string
}

variable "service_ports" {
  description = "Unique container ports exposed by the ECS services."
  type        = set(number)
}

variable "tags" {
  description = "Common tags applied to the security groups."
  type        = map(string)
  default     = {}
}
