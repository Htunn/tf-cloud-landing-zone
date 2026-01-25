output "account_alias" {
  description = "IAM account alias"
  value       = var.account_alias != null ? aws_iam_account_alias.main[0].account_alias : null
}

output "access_analyzer_arn" {
  description = "IAM Access Analyzer ARN"
  value       = var.enable_iam_access_analyzer ? aws_accessanalyzer_analyzer.main[0].arn : null
}

output "access_analyzer_id" {
  description = "IAM Access Analyzer ID"
  value       = var.enable_iam_access_analyzer ? aws_accessanalyzer_analyzer.main[0].id : null
}

output "security_audit_role_arn" {
  description = "Security audit cross-account role ARN"
  value       = var.enable_cross_account_roles ? aws_iam_role.security_audit[0].arn : null
}

output "administrator_access_role_arn" {
  description = "Administrator access cross-account role ARN"
  value       = var.enable_cross_account_roles ? aws_iam_role.administrator_access[0].arn : null
}

output "read_only_access_role_arn" {
  description = "Read-only access cross-account role ARN"
  value       = var.enable_cross_account_roles ? aws_iam_role.read_only_access[0].arn : null
}

output "permission_boundary_arn" {
  description = "IAM permission boundary policy ARN"
  value       = aws_iam_policy.permission_boundary.arn
}
