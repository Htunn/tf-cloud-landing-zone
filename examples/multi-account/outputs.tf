# Organization Outputs
output "organization_id" {
  description = "AWS Organization ID"
  value       = var.organization_id
}

output "organizational_units" {
  description = "Map of created organizational units"
  value = {
    for key, ou in module.landing_zone.organizational_units : key => {
      id   = ou.id
      arn  = ou.arn
      name = ou.name
    }
  }
}

output "service_control_policies" {
  description = "Map of created service control policies"
  value = {
    for key, scp in module.landing_zone.service_control_policies : key => {
      id   = scp.id
      arn  = scp.arn
      name = scp.name
    }
  }
}

# Transit Gateway Outputs
output "transit_gateway_id" {
  description = "Transit Gateway ID"
  value       = module.landing_zone.transit_gateway_id
}

output "transit_gateway_arn" {
  description = "Transit Gateway ARN"
  value       = module.landing_zone.transit_gateway_arn
}

# VPC Outputs (Shared Services)
output "vpc_id" {
  description = "Shared services VPC ID"
  value       = module.landing_zone.vpc_id
}

output "public_subnet_ids" {
  description = "Shared services public subnet IDs"
  value       = module.landing_zone.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Shared services private subnet IDs"
  value       = module.landing_zone.private_subnet_ids
}

# Security Services Outputs
output "guardduty_detector_id" {
  description = "GuardDuty detector ID (organization)"
  value       = module.landing_zone.guardduty_detector_id
}

output "security_hub_arn" {
  description = "Security Hub ARN (organization)"
  value       = module.landing_zone.security_hub_arn
}

output "config_recorder_name" {
  description = "AWS Config recorder name (organization)"
  value       = module.landing_zone.config_recorder_name
}

# Logging Outputs
output "cloudtrail_name" {
  description = "CloudTrail trail name (organization trail)"
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

output "central_logging_bucket" {
  description = "Central logging S3 bucket name"
  value       = module.landing_zone.central_logging_bucket
}

# IAM Outputs
output "iam_access_analyzer_arn" {
  description = "IAM Access Analyzer ARN (organization scope)"
  value       = module.landing_zone.iam_access_analyzer_arn
}

output "permission_boundary_arn" {
  description = "Organization permission boundary ARN"
  value       = module.landing_zone.permission_boundary_arn
}

# Consolidated Organization Summary
output "organization_landing_zone_summary" {
  description = "Complete summary of organization landing zone"
  value = {
    organization = {
      id            = var.organization_id
      root_id       = var.organization_root_id
      management_id = var.organization_master_account_id
    }
    organizational_units = {
      count = length(module.landing_zone.organizational_units)
      units = [for key, ou in module.landing_zone.organizational_units : ou.name]
    }
    service_control_policies = {
      count    = length(module.landing_zone.service_control_policies)
      policies = [for key, scp in module.landing_zone.service_control_policies : scp.name]
    }
    networking = {
      transit_gateway_id = module.landing_zone.transit_gateway_id
      shared_vpc_id      = module.landing_zone.vpc_id
      regions            = var.enabled_regions
    }
    security_services = {
      guardduty    = module.landing_zone.guardduty_detector_id != null ? "enabled" : "disabled"
      security_hub = module.landing_zone.security_hub_arn != null ? "enabled" : "disabled"
      config       = module.landing_zone.config_recorder_name != null ? "enabled" : "disabled"
    }
    logging = {
      organization_trail = module.landing_zone.cloudtrail_name
      cloudtrail_bucket  = module.landing_zone.cloudtrail_s3_bucket
      central_logging    = module.landing_zone.central_logging_bucket
    }
  }
}
