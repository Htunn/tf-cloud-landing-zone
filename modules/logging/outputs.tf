output "cloudtrail_id" {
  description = "CloudTrail ID"
  value       = var.enable_cloudtrail ? aws_cloudtrail.main[0].id : null
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = var.enable_cloudtrail ? aws_cloudtrail.main[0].arn : null
}

output "cloudtrail_bucket_id" {
  description = "CloudTrail S3 bucket ID"
  value       = var.enable_cloudtrail ? aws_s3_bucket.cloudtrail[0].id : null
}

output "cloudtrail_bucket_arn" {
  description = "CloudTrail S3 bucket ARN"
  value       = var.enable_cloudtrail ? aws_s3_bucket.cloudtrail[0].arn : null
}

output "cloudtrail_log_group_arn" {
  description = "CloudTrail CloudWatch Log Group ARN"
  value       = var.enable_cloudtrail ? aws_cloudwatch_log_group.cloudtrail[0].arn : null
}

output "cloudtrail_log_group_name" {
  description = "CloudTrail CloudWatch Log Group name"
  value       = var.enable_cloudtrail ? aws_cloudwatch_log_group.cloudtrail[0].name : null
}

output "centralized_logging_bucket_id" {
  description = "Centralized logging S3 bucket ID"
  value       = var.enable_centralized_logging_bucket ? aws_s3_bucket.logging[0].id : null
}

output "centralized_logging_bucket_arn" {
  description = "Centralized logging S3 bucket ARN"
  value       = var.enable_centralized_logging_bucket ? aws_s3_bucket.logging[0].arn : null
}
