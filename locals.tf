# ============================================================================
# Deployment Mode Logic
# ============================================================================

locals {
  # Derived boolean flags from deployment mode
  is_organization_mode = var.deployment_mode == "organization"
  is_single_account    = var.deployment_mode == "single-account"

  # Effective account IDs based on mode
  primary_account_id = local.is_organization_mode ? var.organization_master_account_id : var.account_id

  # Primary region (first in enabled_regions list)
  primary_region = var.enabled_regions[0]

  # Feature flags based on deployment mode
  features = {
    organization_enabled      = local.is_organization_mode
    service_control_policies  = local.is_organization_mode && length(var.service_control_policies) > 0
    organizational_units      = local.is_organization_mode && length(var.organizational_units) > 0
    cross_account_roles       = local.is_organization_mode && var.enable_cross_account_roles
    guardduty_delegated_admin = local.is_organization_mode && var.enable_guardduty_delegated_admin
    organization_cloudtrail   = local.is_organization_mode && var.enable_cloudtrail
    single_account_baseline   = local.is_single_account
    transit_gateway           = var.enable_transit_gateway && local.is_organization_mode
  }

  # Resource naming
  name_prefix = var.prefix

  # Common tags with deployment mode identifier
  common_tags = merge(
    var.tags,
    {
      DeploymentMode = var.deployment_mode
      CreatedBy      = "terraform-aws-landing-zone"
      Timestamp      = timestamp()
    }
  )

  # Validation helpers
  validate_organization_config = (
    local.is_organization_mode && var.organization_id == null
    ? tobool("ERROR: organization_id is required when deployment_mode is 'organization'")
    : true
  )

  validate_single_account_config = (
    local.is_single_account && var.account_id == null
    ? tobool("ERROR: account_id is required when deployment_mode is 'single-account'")
    : true
  )

  validate_guardduty_delegated_admin = (
    var.enable_guardduty_delegated_admin && var.guardduty_delegated_admin_account_id == null
    ? tobool("ERROR: guardduty_delegated_admin_account_id is required when enable_guardduty_delegated_admin is true")
    : true
  )

  # KMS key configuration
  kms_key_alias = "${local.name_prefix}-key"

  # S3 bucket names (must be globally unique)
  logging_bucket_name = "${local.name_prefix}-logs-${local.primary_account_id}-${local.primary_region}"

  # CloudWatch Log Group names
  vpc_flow_logs_log_group = "/aws/vpc/flowlogs/${local.name_prefix}"
  cloudtrail_log_group    = "/aws/cloudtrail/${local.name_prefix}"
}
