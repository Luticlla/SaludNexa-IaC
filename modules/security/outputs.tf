output "alb_security_group_id" {
  description = "ID of the security group attached to the ALB."
  value       = aws_security_group.alb.id
}

output "tasks_security_group_id" {
  description = "ID of the security group attached to the ECS tasks."
  value       = aws_security_group.tasks.id
}
