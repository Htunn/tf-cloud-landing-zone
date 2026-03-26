# ============================================================================
# Outputs and Configuration Tests
# ============================================================================
# Covers: landing_zone_config composite output structure, security_services
# flags within outputs, logging flags within outputs, naming conventions
# (prefix, KMS alias), custom tags, and encryption output fields.
# ============================================================================

# ============================================================================
# landing_zone_config – Top-Level Fields
# ============================================================================

run "landing_zone_config_contains_deployment_mode" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = output.landing_zone_config.deployment_mode == "single-account"
    error_message = "landing_zone_config.deployment_mode must equal the input variable"
  }
}

run "landing_zone_config_deployment_mode_organization" {
  command = plan

  variables {
    deployment_mode                = "organization"
    organization_id                = "o-1234567890"
    organization_root_id           = "r-abc123"
    organization_master_account_id = "111111111111"
    prefix                         = "test"
  }

  assert {
    condition     = output.landing_zone_config.deployment_mode == "organization"
    error_message = "landing_zone_config.deployment_mode must reflect organization mode"
  }
}

# ============================================================================
# landing_zone_config – security_services Block
# ============================================================================

run "landing_zone_config_security_services_guardduty_enabled" {
  command = plan

  variables {
    deployment_mode  = "single-account"
    account_id       = "123456789012"
    prefix           = "test"
    enable_guardduty = true
  }

  assert {
    condition     = output.landing_zone_config.security_services.guardduty_enabled == true
    error_message = "landing_zone_config.security_services.guardduty_enabled must reflect the enable_guardduty variable"
  }
}

run "landing_zone_config_security_services_guardduty_disabled" {
  command = plan

  variables {
    deployment_mode  = "single-account"
    account_id       = "123456789012"
    prefix           = "test"
    enable_guardduty = false
  }

  assert {
    condition     = output.landing_zone_config.security_services.guardduty_enabled == false
    error_message = "landing_zone_config.security_services.guardduty_enabled must be false when GuardDuty is disabled"
  }
}

run "landing_zone_config_security_services_security_hub_enabled" {
  command = plan

  variables {
    deployment_mode     = "single-account"
    account_id          = "123456789012"
    prefix              = "test"
    enable_security_hub = true
  }

  assert {
    condition     = output.landing_zone_config.security_services.security_hub_enabled == true
    error_message = "landing_zone_config.security_services.security_hub_enabled must reflect enable_security_hub"
  }
}

run "landing_zone_config_security_services_config_enabled" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enable_config   = true
  }

  assert {
    condition     = output.landing_zone_config.security_services.config_enabled == true
    error_message = "landing_zone_config.security_services.config_enabled must reflect enable_config"
  }
}

run "landing_zone_config_security_services_macie_enabled" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enable_macie    = true
  }

  assert {
    condition     = output.landing_zone_config.security_services.macie_enabled == true
    error_message = "landing_zone_config.security_services.macie_enabled must reflect enable_macie"
  }
}

run "landing_zone_config_security_services_macie_disabled_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = output.landing_zone_config.security_services.macie_enabled == false
    error_message = "landing_zone_config.security_services.macie_enabled must be false by default"
  }
}

# ============================================================================
# landing_zone_config – logging Block
# ============================================================================

run "landing_zone_config_logging_cloudtrail_enabled" {
  command = plan

  variables {
    deployment_mode   = "single-account"
    account_id        = "123456789012"
    prefix            = "test"
    enable_cloudtrail = true
  }

  assert {
    condition     = output.landing_zone_config.logging.cloudtrail_enabled == true
    error_message = "landing_zone_config.logging.cloudtrail_enabled must reflect enable_cloudtrail"
  }
}

run "landing_zone_config_logging_cloudtrail_disabled" {
  command = plan

  variables {
    deployment_mode   = "single-account"
    account_id        = "123456789012"
    prefix            = "test"
    enable_cloudtrail = false
  }

  assert {
    condition     = output.landing_zone_config.logging.cloudtrail_enabled == false
    error_message = "landing_zone_config.logging.cloudtrail_enabled must be false when CloudTrail is disabled"
  }
}

run "landing_zone_config_logging_vpc_flow_logs_enabled" {
  command = plan

  variables {
    deployment_mode      = "single-account"
    account_id           = "123456789012"
    prefix               = "test"
    enable_vpc_flow_logs = true
  }

  assert {
    condition     = output.landing_zone_config.logging.vpc_flow_logs_enabled == true
    error_message = "landing_zone_config.logging.vpc_flow_logs_enabled must reflect enable_vpc_flow_logs"
  }
}

run "landing_zone_config_logging_vpc_flow_logs_disabled" {
  command = plan

  variables {
    deployment_mode      = "single-account"
    account_id           = "123456789012"
    prefix               = "test"
    enable_vpc_flow_logs = false
  }

  assert {
    condition     = output.landing_zone_config.logging.vpc_flow_logs_enabled == false
    error_message = "landing_zone_config.logging.vpc_flow_logs_enabled must be false when VPC Flow Logs are disabled"
  }
}

# ============================================================================
# landing_zone_config – encryption Block
# ============================================================================

run "landing_zone_config_encryption_kms_enabled" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enable_kms_key  = true
  }

  assert {
    condition     = output.landing_zone_config.encryption.kms_key_enabled == true
    error_message = "landing_zone_config.encryption.kms_key_enabled must be true when KMS key is enabled"
  }
}

run "landing_zone_config_encryption_kms_disabled" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enable_kms_key  = false
  }

  assert {
    condition     = output.landing_zone_config.encryption.kms_key_enabled == false
    error_message = "landing_zone_config.encryption.kms_key_enabled must be false when KMS key is disabled"
  }

  assert {
    condition     = output.landing_zone_config.encryption.kms_key_arn == null
    error_message = "landing_zone_config.encryption.kms_key_arn must be null when KMS key is disabled"
  }
}

# ============================================================================
# landing_zone_config – organization Block (mode-conditional)
# ============================================================================

run "landing_zone_config_organization_null_in_single_account" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = output.landing_zone_config.organization == null
    error_message = "landing_zone_config.organization must be null in single-account mode"
  }
}

run "landing_zone_config_organization_populated_in_org_mode" {
  command = plan

  variables {
    deployment_mode                = "organization"
    organization_id                = "o-1234567890"
    organization_root_id           = "r-abc123"
    organization_master_account_id = "111111111111"
    prefix                         = "test"
  }

  assert {
    condition     = output.landing_zone_config.organization != null
    error_message = "landing_zone_config.organization must not be null in organization mode"
  }

  assert {
    condition     = output.landing_zone_config.organization.id == "o-1234567890"
    error_message = "landing_zone_config.organization.id must match the input organization_id"
  }

  assert {
    condition     = output.landing_zone_config.organization.root_id == "r-abc123"
    error_message = "landing_zone_config.organization.root_id must match the input organization_root_id"
  }
}

# ============================================================================
# Prefix and Resource Naming
# ============================================================================

run "prefix_single_char_valid" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "a"
  }

  assert {
    condition     = can(regex("^[a-z0-9-]+$", var.prefix))
    error_message = "Single lowercase character prefix must be accepted"
  }
}

run "prefix_numbers_and_hyphens_valid" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "lz-01"
  }

  assert {
    condition     = can(regex("^[a-z0-9-]+$", var.prefix))
    error_message = "Prefix with numbers and hyphens must be accepted"
  }
}

run "prefix_uppercase_invalid" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "LandingZone"
  }

  expect_failures = [
    var.prefix
  ]
}

run "prefix_with_underscore_invalid" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "landing_zone"
  }

  expect_failures = [
    var.prefix
  ]
}

run "prefix_with_spaces_invalid" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "landing zone"
  }

  expect_failures = [
    var.prefix
  ]
}

# ============================================================================
# Custom Tags
# ============================================================================

run "custom_tags_single_account" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    tags = {
      Environment = "staging"
      Team        = "platform"
      CostCenter  = "12345"
    }
  }

  assert {
    condition     = var.tags["Environment"] == "staging"
    error_message = "Custom Environment tag must be accepted"
  }

  assert {
    condition     = var.tags["Team"] == "platform"
    error_message = "Custom Team tag must be accepted"
  }

  assert {
    condition     = var.tags["CostCenter"] == "12345"
    error_message = "Custom CostCenter tag must be accepted"
  }
}

run "custom_tags_organization_mode" {
  command = plan

  variables {
    deployment_mode                = "organization"
    organization_id                = "o-1234567890"
    organization_root_id           = "r-abc123"
    organization_master_account_id = "111111111111"
    prefix                         = "test"
    tags = {
      Environment = "production"
      Owner       = "cloud-team"
    }
  }

  assert {
    condition     = var.tags["Environment"] == "production"
    error_message = "Custom tags must be accepted in organization mode"
  }
}

run "default_tags_include_managed_by_terraform" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.tags["ManagedBy"] == "terraform"
    error_message = "Default tags must include ManagedBy=terraform"
  }

  assert {
    condition     = var.tags["Module"] == "aws-landing-zone"
    error_message = "Default tags must include Module=aws-landing-zone"
  }
}
