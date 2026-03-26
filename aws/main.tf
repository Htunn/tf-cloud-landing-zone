# ============================================================================
# AWS Landing Zone - Main Module
# ============================================================================
# This module deploys an AWS landing zone that supports two deployment modes:
# - single-account: Security baseline for a single AWS account
# - organization: Multi-account setup with AWS Organizations
# ============================================================================

# Get current AWS account and region information
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Get availability zones for VPC subnet distribution
data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================================================
# Deployment Mode Validation Checks
# ============================================================================

check "deployment_mode_requirements" {
  assert {
    condition = (
      var.deployment_mode != "organization" ||
      (var.organization_id != null && var.organization_root_id != null)
    )
    error_message = "Organization mode requires organization_id and organization_root_id to be specified."
  }

  assert {
    condition = (
      var.deployment_mode != "single-account" ||
      var.account_id != null
    )
    error_message = "Single-account mode requires account_id to be specified."
  }

  assert {
    condition = (
      !var.enable_guardduty_delegated_admin ||
      var.guardduty_delegated_admin_account_id != null
    )
    error_message = "GuardDuty delegated admin requires guardduty_delegated_admin_account_id to be specified."
  }
}

# ============================================================================
# KMS Encryption Key
# ============================================================================

resource "aws_kms_key" "main" {
  count = var.enable_kms_key ? 1 : 0

  description             = "KMS key for ${local.name_prefix} landing zone encryption"
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-key"
    }
  )
}

resource "aws_kms_alias" "main" {
  count = var.enable_kms_key ? 1 : 0

  name          = "alias/${local.kms_key_alias}"
  target_key_id = aws_kms_key.main[0].key_id
}

# ============================================================================
# Organization Module (Organization Mode Only)
# ============================================================================

module "organization" {
  source = "../modules/aws/organization"
  count  = local.is_organization_mode ? 1 : 0

  organization_id          = var.organization_id
  organization_root_id     = var.organization_root_id
  organizational_units     = var.organizational_units
  service_control_policies = var.service_control_policies

  prefix = local.name_prefix
  tags   = local.common_tags
}

# ============================================================================
# Networking Module
# ============================================================================

module "networking" {
  source = "../modules/aws/networking"

  deployment_mode    = var.deployment_mode
  vpc_cidr           = var.vpc_cidr
  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, min(3, length(data.aws_availability_zones.available.names)))

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  enable_vpc_flow_logs   = var.enable_vpc_flow_logs
  enable_transit_gateway = var.enable_transit_gateway && local.is_organization_mode

  flow_logs_log_group_name = local.vpc_flow_logs_log_group
  kms_key_id               = var.enable_kms_key ? aws_kms_key.main[0].arn : null

  prefix = local.name_prefix
  tags   = local.common_tags
}

# ============================================================================
# IAM Module
# ============================================================================

module "iam" {
  source = "../modules/aws/iam"

  deployment_mode            = var.deployment_mode
  account_alias              = var.account_alias
  enable_iam_access_analyzer = var.enable_iam_access_analyzer
  iam_password_policy        = var.iam_password_policy
  enable_cross_account_roles = var.enable_cross_account_roles && local.is_organization_mode

  organization_id = local.is_organization_mode ? var.organization_id : null

  prefix = local.name_prefix
  tags   = local.common_tags
}

# ============================================================================
# Security Module
# ============================================================================

module "security" {
  source = "../modules/aws/security"

  deployment_mode = var.deployment_mode
  enabled_regions = var.enabled_regions
  primary_region  = local.primary_region

  # GuardDuty Configuration
  enable_guardduty                       = var.enable_guardduty
  enable_guardduty_delegated_admin       = var.enable_guardduty_delegated_admin && local.is_organization_mode
  guardduty_delegated_admin_account_id   = var.guardduty_delegated_admin_account_id
  guardduty_finding_publishing_frequency = var.guardduty_finding_publishing_frequency

  # Security Hub Configuration
  enable_security_hub                           = var.enable_security_hub
  enable_security_hub_cis_standard              = var.enable_security_hub_cis_standard
  enable_security_hub_aws_foundational_standard = var.enable_security_hub_aws_foundational_standard

  # AWS Config Configuration
  enable_config = var.enable_config

  # Macie Configuration
  enable_macie = var.enable_macie

  kms_key_id = var.enable_kms_key ? aws_kms_key.main[0].arn : null

  prefix = local.name_prefix
  tags   = local.common_tags
}

# ============================================================================
# Logging Module
# ============================================================================

module "logging" {
  source = "../modules/aws/logging"

  deployment_mode = var.deployment_mode
  primary_region  = local.primary_region
  account_id      = local.primary_account_id
  organization_id = local.is_organization_mode ? var.organization_id : null

  enable_cloudtrail                     = var.enable_cloudtrail
  cloudtrail_enable_log_file_validation = var.cloudtrail_enable_log_file_validation
  is_organization_trail                 = local.is_organization_mode

  enable_centralized_logging_bucket = var.enable_centralized_logging_bucket
  cloudwatch_log_retention_days     = var.cloudwatch_log_retention_days

  kms_key_id = var.enable_kms_key ? aws_kms_key.main[0].arn : null

  prefix = local.name_prefix
  tags   = local.common_tags
}

# ============================================================================
# Outputs
# ============================================================================

# Module outputs are defined in outputs.tf
