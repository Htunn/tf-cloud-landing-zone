# ============================================================================
# Common Outputs (Both Deployment Modes)
# ============================================================================

output "deployment_mode" {
  description = "Active deployment mode (single-account or organization)"
  value       = var.deployment_mode
}

output "region" {
  description = "Primary AWS region"
  value       = data.aws_region.current.id
}

output "account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "kms_key_id" {
  description = "KMS key ID for encryption"
  value       = module.kms.kms_key_id
}

output "kms_key_arn" {
  description = "KMS key ARN for encryption"
  value       = module.kms.kms_key_arn
}

# ============================================================================
# Organization Mode Outputs
# ============================================================================

output "organization" {
  description = "Organization details (only populated in organization mode)"
  value = local.is_organization_mode ? {
    id                       = var.organization_id
    root_id                  = var.organization_root_id
    master_account_id        = var.organization_master_account_id
    organizational_units     = try(module.organization[0].organizational_units, {})
    service_control_policies = try(module.organization[0].service_control_policies, {})
  } : null
}

# ============================================================================
# Single Account Mode Outputs
# ============================================================================

output "account" {
  description = "Account details (only populated in single-account mode)"
  value = local.is_single_account ? {
    id     = var.account_id
    alias  = var.account_alias
    region = data.aws_region.current.id
  } : null
}

# ============================================================================
# Networking Outputs
# ============================================================================

output "networking" {
  description = "Networking module outputs"
  value = {
    vpc_id                  = module.networking.vpc_id
    vpc_cidr                = module.networking.vpc_cidr
    private_subnet_ids      = module.networking.private_subnet_ids
    public_subnet_ids       = module.networking.public_subnet_ids
    nat_gateway_ids         = module.networking.nat_gateway_ids
    internet_gateway_id     = module.networking.internet_gateway_id
    transit_gateway_id      = try(module.networking.transit_gateway_id, null)
    flow_logs_log_group_arn = try(module.networking.flow_logs_log_group_arn, null)
  }
}

# ============================================================================
# Security Outputs
# ============================================================================

output "security" {
  description = "Security module outputs"
  value = {
    guardduty_detector_id = try(module.security.guardduty_detector_id, null)
    security_hub_arn      = try(module.security.security_hub_arn, null)
    config_recorder_name  = try(module.security.config_recorder_name, null)
    access_analyzer_arn   = try(module.iam.access_analyzer_arn, null)
  }
}

# ============================================================================
# Logging Outputs
# ============================================================================

output "logging" {
  description = "Logging module outputs"
  value = {
    cloudtrail_arn                = try(module.logging.cloudtrail_arn, null)
    cloudtrail_bucket_id          = try(module.logging.cloudtrail_bucket_id, null)
    centralized_logging_bucket_id = try(module.logging.centralized_logging_bucket_id, null)
    cloudtrail_log_group_arn      = try(module.logging.cloudtrail_log_group_arn, null)
  }
}

# ============================================================================
# ECR Outputs
# ============================================================================

output "ecr" {
  description = "ECR module outputs"
  value = {
    repository_urls  = module.ecr.repository_urls
    repository_arns  = module.ecr.repository_arns
    repository_names = module.ecr.repository_names
  }
}

# ============================================================================
# Compute Outputs
# ============================================================================

output "compute" {
  description = "Compute module outputs"
  value = {
    ecs_cluster_arn           = module.compute.ecs_cluster_arn
    ecs_cluster_name          = module.compute.ecs_cluster_name
    lambda_execution_role_arn = module.compute.lambda_execution_role_arn
    lambda_log_group_name     = module.compute.lambda_log_group_name
    ec2_launch_template_id    = module.compute.ec2_launch_template_id
    ec2_security_group_id     = module.compute.ec2_security_group_id
    ec2_asg_name              = module.compute.ec2_asg_name
  }
}

# ============================================================================
# Database Outputs
# ============================================================================

output "database" {
  description = "Database module outputs"
  value = {
    rds_cluster_endpoint        = module.database.rds_cluster_endpoint
    rds_cluster_reader_endpoint = module.database.rds_cluster_reader_endpoint
    rds_cluster_id              = module.database.rds_cluster_id
    rds_security_group_id       = module.database.rds_security_group_id
    dynamodb_table_name         = module.database.dynamodb_table_name
    dynamodb_table_arn          = module.database.dynamodb_table_arn
  }
}

# ============================================================================
# Unified Landing Zone Configuration Output
# ============================================================================

output "landing_zone_config" {
  description = "Complete landing zone configuration and resource details"
  value = {
    deployment_mode = var.deployment_mode
    region          = data.aws_region.current.id
    account_id      = data.aws_caller_identity.current.account_id

    organization = local.is_organization_mode ? {
      id                       = var.organization_id
      root_id                  = var.organization_root_id
      master_account_id        = var.organization_master_account_id
      organizational_units     = try(module.organization[0].organizational_units, {})
      service_control_policies = try(module.organization[0].service_control_policies, {})
    } : null

    networking = {
      vpc_id             = module.networking.vpc_id
      vpc_cidr           = module.networking.vpc_cidr
      availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, min(3, length(data.aws_availability_zones.available.names)))
    }

    security_services = {
      guardduty_enabled    = var.enable_guardduty
      security_hub_enabled = var.enable_security_hub
      config_enabled       = var.enable_config
      macie_enabled        = var.enable_macie
    }

    logging = {
      cloudtrail_enabled    = var.enable_cloudtrail
      vpc_flow_logs_enabled = var.enable_vpc_flow_logs
    }

    encryption = {
      kms_key_enabled = var.enable_kms_key
      kms_key_arn     = module.kms.kms_key_arn
    }

    compute = {
      ecs_enabled    = var.enable_ecs
      lambda_enabled = var.enable_lambda_baseline
      ec2_enabled    = var.enable_ec2
    }

    database = {
      rds_enabled      = var.enable_rds
      dynamodb_enabled = var.enable_dynamodb
    }
  }
}
