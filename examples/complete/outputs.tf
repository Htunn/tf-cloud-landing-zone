# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.landing_zone.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.landing_zone.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.landing_zone.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "IDs of NAT Gateways"
  value       = module.landing_zone.nat_gateway_ids
}

# Security Outputs
output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = module.landing_zone.guardduty_detector_id
}

output "security_hub_arn" {
  description = "Security Hub ARN"
  value       = module.landing_zone.security_hub_arn
}

output "config_recorder_name" {
  description = "AWS Config recorder name"
  value       = module.landing_zone.config_recorder_name
}

output "macie_account_id" {
  description = "Macie member account ID"
  value       = module.landing_zone.macie_account_id
}

# Logging Outputs
output "cloudtrail_name" {
  description = "CloudTrail trail name"
  value       = module.landing_zone.cloudtrail_name
}

output "cloudtrail_arn" {
  description = "CloudTrail trail ARN"
  value       = module.landing_zone.cloudtrail_arn
}

output "cloudtrail_s3_bucket" {
  description = "CloudTrail S3 bucket name"
  value       = module.landing_zone.cloudtrail_s3_bucket
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  value       = module.landing_zone.cloudwatch_log_group_name
}

output "central_logging_bucket" {
  description = "Central logging S3 bucket name"
  value       = module.landing_zone.central_logging_bucket
}

# IAM Outputs
output "iam_access_analyzer_arn" {
  description = "IAM Access Analyzer ARN"
  value       = module.landing_zone.iam_access_analyzer_arn
}

output "security_audit_role_arn" {
  description = "Security audit role ARN"
  value       = module.landing_zone.security_audit_role_arn
}

output "admin_role_arn" {
  description = "Admin role ARN"
  value       = module.landing_zone.admin_role_arn
}

output "read_only_role_arn" {
  description = "Read-only role ARN"
  value       = module.landing_zone.read_only_role_arn
}

output "permission_boundary_arn" {
  description = "Permission boundary policy ARN"
  value       = module.landing_zone.permission_boundary_arn
}

# KMS Outputs
output "kms_key_id" {
  description = "KMS key ID for encryption"
  value       = module.landing_zone.kms_key_id
}

output "kms_key_arn" {
  description = "KMS key ARN for encryption"
  value       = module.landing_zone.kms_key_arn
}

# Consolidated Output
output "landing_zone_summary" {
  description = "Summary of deployed landing zone resources"
  value = {
    deployment_mode = "single-account"
    account_id      = var.account_id
    region          = var.primary_region
    vpc_id          = module.landing_zone.vpc_id
    security_services = {
      guardduty    = module.landing_zone.guardduty_detector_id != null ? "enabled" : "disabled"
      security_hub = module.landing_zone.security_hub_arn != null ? "enabled" : "disabled"
      config       = module.landing_zone.config_recorder_name != null ? "enabled" : "disabled"
      macie        = module.landing_zone.macie_account_id != null ? "enabled" : "disabled"
    }
    logging = {
      cloudtrail      = module.landing_zone.cloudtrail_name
      cloudwatch_logs = module.landing_zone.cloudwatch_log_group_name
      s3_logging      = module.landing_zone.central_logging_bucket
    }
  }
}
