variable "name_prefix" {
  description = "Prefix used to name the network resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Primary AZ for compute and the secondary AZ required by the ALB."
  type = object({
    primary   = string
    secondary = string
  })
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets in the primary and secondary AZs."
  type = object({
    a = string
    b = string
  })
}

variable "app_subnet_cidr" {
  description = "CIDR block for the private application subnet in the primary AZ."
  type        = string
}

variable "tags" {
  description = "Common tags applied to network resources."
  type        = map(string)
  default     = {}
}
