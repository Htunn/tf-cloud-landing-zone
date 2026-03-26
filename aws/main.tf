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
# KMS Module
# ============================================================================

module "kms" {
  source = "../modules/aws/kms"

  enable_kms_key                  = var.enable_kms_key
  kms_key_deletion_window_in_days = var.kms_key_deletion_window_in_days
  kms_key_alias                   = local.kms_key_alias
  enable_multi_region             = var.enable_kms_multi_region
  key_administrators              = var.kms_key_administrators
  key_users                       = var.kms_key_users

  prefix = local.name_prefix
  tags   = local.common_tags
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
  kms_key_id               = module.kms.kms_key_arn

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

  kms_key_id = module.kms.kms_key_arn

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

  kms_key_id = module.kms.kms_key_arn

  prefix = local.name_prefix
  tags   = local.common_tags
}

# ============================================================================
# ECR Module
# ============================================================================

module "ecr" {
  source = "../modules/aws/ecr"

  repositories                = var.ecr_repositories
  lifecycle_policy_keep_count = var.ecr_lifecycle_policy_keep_count
  untagged_image_expiry_days  = var.ecr_untagged_image_expiry_days
  kms_key_arn                 = module.kms.kms_key_arn
  enable_cross_account_pull   = var.ecr_enable_cross_account_pull
  cross_account_ids           = var.ecr_cross_account_ids

  prefix = local.name_prefix
  tags   = local.common_tags
}

# ============================================================================
# Compute Module
# ============================================================================

module "compute" {
  source = "../modules/aws/compute"

  enable_ecs                = var.enable_ecs
  ecs_cluster_name          = var.ecs_cluster_name
  enable_container_insights = var.enable_container_insights

  enable_lambda_baseline    = var.enable_lambda_baseline
  lambda_log_retention_days = var.lambda_log_retention_days

  enable_ec2           = var.enable_ec2
  enable_asg           = var.enable_asg
  ec2_instance_type    = var.ec2_instance_type
  ec2_ami_id           = var.ec2_ami_id
  ec2_min_size         = var.ec2_min_size
  ec2_max_size         = var.ec2_max_size
  ec2_desired_capacity = var.ec2_desired_capacity

  vpc_id      = module.networking.vpc_id
  subnet_ids  = module.networking.private_subnet_ids
  kms_key_arn = module.kms.kms_key_arn

  prefix = local.name_prefix
  tags   = local.common_tags
}

# ============================================================================
# Database Module
# ============================================================================

module "database" {
  source = "../modules/aws/database"

  enable_rds      = var.enable_rds
  enable_dynamodb = var.enable_dynamodb

  db_engine                   = var.db_engine
  db_engine_version           = var.db_engine_version
  db_cluster_identifier       = var.db_cluster_identifier
  db_name                     = var.db_name
  db_master_username          = var.db_master_username
  db_master_password          = var.db_master_password
  db_instance_class           = var.db_instance_class
  db_instance_count           = var.db_instance_count
  db_min_capacity             = var.db_min_capacity
  db_max_capacity             = var.db_max_capacity
  enable_deletion_protection  = var.db_enable_deletion_protection
  skip_final_snapshot         = var.db_skip_final_snapshot
  backup_retention_period     = var.db_backup_retention_period
  preferred_backup_window     = var.db_preferred_backup_window
  enable_performance_insights = var.db_enable_performance_insights

  dynamodb_table_name           = var.dynamodb_table_name
  dynamodb_billing_mode         = var.dynamodb_billing_mode
  dynamodb_hash_key             = var.dynamodb_hash_key
  dynamodb_hash_key_type        = var.dynamodb_hash_key_type
  dynamodb_range_key            = var.dynamodb_range_key
  dynamodb_range_key_type       = var.dynamodb_range_key_type
  enable_point_in_time_recovery = var.dynamodb_enable_point_in_time_recovery

  vpc_id              = module.networking.vpc_id
  subnet_ids          = module.networking.private_subnet_ids
  allowed_cidr_blocks = var.db_allowed_cidr_blocks
  kms_key_arn         = module.kms.kms_key_arn

  prefix = local.name_prefix
  tags   = local.common_tags
}

# ============================================================================
# Outputs
# ============================================================================

# Module outputs are defined in outputs.tf
