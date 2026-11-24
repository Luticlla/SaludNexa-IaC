output "project" {
  description = "Project name."
  value       = var.project
}

output "environment" {
  description = "Deployment environment."
  value       = var.environment
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the two public subnets required by the ALB."
  value       = module.network.public_subnet_ids
}

output "app_subnet_ids" {
  description = "IDs of the private application subnets used by ECS tasks."
  value       = module.network.app_subnet_ids
}

output "nat_gateway_id" {
  description = "ID of the NAT gateway used by private tasks."
  value       = module.network.nat_gateway_id
}

output "alb_security_group_id" {
  description = "ID of the security group attached to the ALB."
  value       = module.security.alb_security_group_id
}

output "tasks_security_group_id" {
  description = "ID of the security group attached to the ECS tasks."
  value       = module.security.tasks_security_group_id
}

output "execution_role_arn" {
  description = "ARN of the shared ECS task execution role."
  value       = module.iam.execution_role_arn
}

output "execution_role_name" {
  description = "Name of the shared ECS task execution role."
  value       = module.iam.execution_role_name
}

output "task_role_arns" {
  description = "ARNs of the per-service ECS task roles."
  value       = module.iam.task_role_arns
}

output "task_role_names" {
  description = "Names of the per-service ECS task roles."
  value       = module.iam.task_role_names
}

output "ecr_repository_urls" {
  description = "URLs of the ECR repositories keyed by service name."
  value       = module.ecr.repository_urls
}

output "ecr_repository_arns" {
  description = "ARNs of the ECR repositories keyed by service name."
  value       = module.ecr.repository_arns
}

output "ecr_repository_names" {
  description = "Names of the ECR repositories keyed by service name."
  value       = module.ecr.repository_names
}

output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.ecs.cluster_name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = module.ecs.cluster_arn
}

output "log_group_names" {
  description = "CloudWatch log group names keyed by service name."
  value       = module.ecs.log_group_names
}

output "task_definition_arns" {
  description = "Task definition ARNs keyed by service name."
  value       = module.ecs.task_definition_arns
}

output "task_definition_families" {
  description = "Task definition families keyed by service name."
  value       = module.ecs.task_definition_families
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the Application Load Balancer."
  value       = module.alb.alb_zone_id
}

output "alb_url" {
  description = "URL of the ALB listener."
  value       = var.certificate_arn == "" ? "http://${module.alb.alb_dns_name}" : "https://${module.alb.alb_dns_name}"
}

output "listener_arn" {
  description = "ARN of the ALB listener."
  value       = module.alb.listener_arn
}

output "target_group_arns" {
  description = "Target group ARNs keyed by service name."
  value       = module.alb.target_group_arns
}

output "service_names" {
  description = "ECS service names keyed by service name."
  value       = module.ecs.service_names
}

output "service_ids" {
  description = "ECS service IDs keyed by service name."
  value       = module.ecs.service_ids
}

output "autoscaling_target_ids" {
  description = "Application Auto Scaling target IDs keyed by service name."
  value       = module.ecs.autoscaling_target_ids
}

output "cpu_alarm_arns" {
  description = "CloudWatch CPU alarm ARNs keyed by service name."
  value       = module.ecs.cpu_alarm_arns
}

output "alb_5xx_alarm_arn" {
  description = "ARN of the ALB 5xx rate alarm."
  value       = module.alb.alb_5xx_alarm_arn
}
