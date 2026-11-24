output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.this.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = aws_ecs_cluster.this.arn
}

output "log_group_names" {
  description = "CloudWatch log group names keyed by service name."
  value       = { for name, log_group in aws_cloudwatch_log_group.service : name => log_group.name }
}

output "log_group_arns" {
  description = "CloudWatch log group ARNs keyed by service name."
  value       = { for name, log_group in aws_cloudwatch_log_group.service : name => log_group.arn }
}

output "task_definition_arns" {
  description = "Task definition ARNs keyed by service name."
  value       = { for name, task_definition in aws_ecs_task_definition.this : name => task_definition.arn }
}

output "task_definition_families" {
  description = "Task definition families keyed by service name."
  value       = { for name, task_definition in aws_ecs_task_definition.this : name => task_definition.family }
}

output "service_names" {
  description = "ECS service names keyed by service name."
  value       = { for name, service in aws_ecs_service.this : name => service.name }
}

output "service_ids" {
  description = "ECS service IDs keyed by service name."
  value       = { for name, service in aws_ecs_service.this : name => service.id }
}

output "autoscaling_target_ids" {
  description = "Application Auto Scaling target IDs keyed by service name."
  value       = { for name, target in aws_appautoscaling_target.this : name => target.id }
}

output "cpu_alarm_arns" {
  description = "CloudWatch CPU alarm ARNs keyed by service name."
  value       = { for name, alarm in aws_cloudwatch_metric_alarm.cpu_high : name => alarm.arn }
}
