variable "name_prefix" {
  description = "Prefijo usado para nombrar la clave KMS y sus recursos de monitoreo."
  type        = string
}

variable "tags" {
  description = "Tags comunes aplicados a los recursos de monitoreo."
  type        = map(string)
  default     = {}
}
