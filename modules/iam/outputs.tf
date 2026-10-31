output "execution_role_arn" {
  description = "ARN of the shared ECS task execution role."
  value       = aws_iam_role.execution.arn
}

output "execution_role_name" {
  description = "Name of the shared ECS task execution role."
  value       = aws_iam_role.execution.name
}

output "task_role_arns" {
  description = "ARNs of the per-service ECS task roles."
  value       = { for name, role in aws_iam_role.task : name => role.arn }
}

output "task_role_names" {
  description = "Names of the per-service ECS task roles."
  value       = { for name, role in aws_iam_role.task : name => role.name }
}
