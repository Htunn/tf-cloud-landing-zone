output "repository_urls" {
  description = "Map of repository key to repository URL"
  value       = { for k, v in aws_ecr_repository.main : k => v.repository_url }
}

output "repository_arns" {
  description = "Map of repository key to repository ARN"
  value       = { for k, v in aws_ecr_repository.main : k => v.arn }
}

output "repository_names" {
  description = "Map of repository key to full repository name"
  value       = { for k, v in aws_ecr_repository.main : k => v.name }
}

output "registry_id" {
  description = "AWS account ID associated with the ECR registry"
  value       = length(aws_ecr_repository.main) > 0 ? values(aws_ecr_repository.main)[0].registry_id : null
}
