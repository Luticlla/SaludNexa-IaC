variable "name_prefix" {
  description = "Prefijo usado para nombrar la clave KMS y sus recursos de monitoreo."
  type        = string
}

variable "alert_email" {
  description = "Correo que recibe las notificaciones de las alarmas. Si está vacío no se crea la suscripción."
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Nombre del clúster ECS que se grafica en el dashboard."
  type        = string
}

variable "service_names" {
  description = "Nombres de los servicios ECS por clave, usados como dimensión ServiceName"
  type        = map(string)
}

variable "alb_arn_suffix" {
  description = "ARN suffix del ALB usado como dimensión LoadBalancer."
  type        = string
}

variable "tags" {
  description = "Tags comunes aplicados a los recursos de monitoreo."
  type        = map(string)
  default     = {}
}
