output "vpc_id" {
  description = "VPC ID"
  value       = module.landing_zone.networking.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.landing_zone.networking.vpc_cidr
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.landing_zone.networking.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.landing_zone.networking.public_subnet_ids
}

output "security_services" {
  description = "Security services configuration"
  value = {
    guardduty_detector_id = module.landing_zone.security.guardduty_detector_id
    security_hub_arn      = module.landing_zone.security.security_hub_arn
  }
}

output "logging_config" {
  description = "Logging configuration"
  value = {
    cloudtrail_arn    = module.landing_zone.logging.cloudtrail_arn
    cloudtrail_bucket = module.landing_zone.logging.cloudtrail_bucket_id
  }
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = module.landing_zone.kms_key_arn
}
