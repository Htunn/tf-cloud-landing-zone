output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = var.enable_guardduty ? aws_guardduty_detector.main[0].id : null
}

output "guardduty_detector_arn" {
  description = "GuardDuty detector ARN"
  value       = var.enable_guardduty ? aws_guardduty_detector.main[0].arn : null
}

output "security_hub_arn" {
  description = "Security Hub ARN"
  value       = var.enable_security_hub ? aws_securityhub_account.main[0].arn : null
}

output "security_hub_id" {
  description = "Security Hub ID"
  value       = var.enable_security_hub ? aws_securityhub_account.main[0].id : null
}

output "config_recorder_name" {
  description = "AWS Config recorder name"
  value       = var.enable_config ? aws_config_configuration_recorder.main[0].name : null
}

output "config_bucket_id" {
  description = "AWS Config S3 bucket ID"
  value       = var.enable_config ? aws_s3_bucket.config[0].id : null
}

output "config_bucket_arn" {
  description = "AWS Config S3 bucket ARN"
  value       = var.enable_config ? aws_s3_bucket.config[0].arn : null
}

output "macie_account_id" {
  description = "Macie account ID"
  value       = var.enable_macie ? aws_macie2_account.main[0].id : null
}
