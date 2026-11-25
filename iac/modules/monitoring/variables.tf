variable "name_prefix" {
  description = "Prefijo usado para nombrar la clave KMS y sus recursos de monitoreo."
  type        = string
}

variable "alert_email" {
  description = "Correo que recibe las notificaciones de las alarmas. Si está vacío no se crea la suscripción."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags comunes aplicados a los recursos de monitoreo."
  type        = map(string)
  default     = {}
}
