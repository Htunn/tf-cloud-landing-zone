output "kms_key_id" {
  description = "KMS key ID"
  value       = var.enable_kms_key ? aws_kms_key.main[0].key_id : null
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = var.enable_kms_key ? aws_kms_key.main[0].arn : null
}

output "kms_alias_name" {
  description = "KMS key alias name"
  value       = var.enable_kms_key ? aws_kms_alias.main[0].name : null
}

output "kms_alias_arn" {
  description = "KMS key alias ARN"
  value       = var.enable_kms_key ? aws_kms_alias.main[0].arn : null
}
