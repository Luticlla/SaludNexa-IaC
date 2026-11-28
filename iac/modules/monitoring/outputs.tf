output "kms_key_arn" {
  description = "ARN de la clave KMS usada para cifrar logs y alertas."
  value       = aws_kms_key.this.arn
}

output "sns_topic_arn" {
  description = "ARN del tema SNS que notifica las alarmas."
  value       = aws_sns_topic.alerts.arn
}
