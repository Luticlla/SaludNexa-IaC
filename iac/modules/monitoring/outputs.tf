output "kms_key_arn" {
  description = "ARN de la clave KMS usada para cifrar logs y alertas."
  value       = aws_kms_key.this.arn
}
