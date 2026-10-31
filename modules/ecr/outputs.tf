output "repository_urls" {
  description = "URLs of the ECR repositories keyed by service name."
  value       = { for name, repository in aws_ecr_repository.this : name => repository.repository_url }
}

output "repository_arns" {
  description = "ARNs of the ECR repositories keyed by service name."
  value       = { for name, repository in aws_ecr_repository.this : name => repository.arn }
}

output "repository_names" {
  description = "Names of the ECR repositories keyed by service name."
  value       = { for name, repository in aws_ecr_repository.this : name => repository.name }
}
