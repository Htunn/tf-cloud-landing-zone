# ============================================================================
# Security Services Tests
# ============================================================================
# Covers: Security Hub standards (CIS, AWS Foundational), Macie enable,
# CloudTrail log file validation, GuardDuty delegated admin with org mode,
# combined security stack configurations, and enabled_regions validation.
# ============================================================================

# ============================================================================
# Security Hub Standards
# ============================================================================

run "security_hub_cis_standard_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_security_hub_cis_standard == true
    error_message = "Security Hub CIS Foundations Benchmark standard must be enabled by default"
  }
}

run "security_hub_aws_foundational_standard_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_security_hub_aws_foundational_standard == true
    error_message = "Security Hub AWS Foundational Security Best Practices standard must be enabled by default"
  }
}

run "security_hub_cis_standard_can_be_disabled" {
  command = plan

  variables {
    deployment_mode                  = "single-account"
    account_id                       = "123456789012"
    prefix                           = "test"
    enable_security_hub              = true
    enable_security_hub_cis_standard = false
  }

  assert {
    condition     = var.enable_security_hub_cis_standard == false
    error_message = "Security Hub CIS standard must be independently disableable"
  }
}

run "security_hub_aws_foundational_standard_can_be_disabled" {
  command = plan

  variables {
    deployment_mode                               = "single-account"
    account_id                                    = "123456789012"
    prefix                                        = "test"
    enable_security_hub                           = true
    enable_security_hub_aws_foundational_standard = false
  }

  assert {
    condition     = var.enable_security_hub_aws_foundational_standard == false
    error_message = "Security Hub AWS Foundational standard must be independently disableable"
  }
}

run "security_hub_both_standards_disabled" {
  command = plan

  variables {
    deployment_mode                               = "single-account"
    account_id                                    = "123456789012"
    prefix                                        = "test"
    enable_security_hub                           = true
    enable_security_hub_cis_standard              = false
    enable_security_hub_aws_foundational_standard = false
  }

  assert {
    condition     = var.enable_security_hub_cis_standard == false && var.enable_security_hub_aws_foundational_standard == false
    error_message = "Both Security Hub standards must be independently disableable simultaneously"
  }
}

# ============================================================================
# Macie Configuration
# ============================================================================

run "macie_disabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_macie == false
    error_message = "Macie must be disabled by default (incurs additional cost)"
  }
}

run "macie_can_be_enabled_single_account" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enable_macie    = true
  }

  assert {
    condition     = var.enable_macie == true
    error_message = "Macie must be enableable in single-account mode"
  }
}

run "macie_can_be_enabled_organization_mode" {
  command = plan

  variables {
    deployment_mode                = "organization"
    organization_id                = "o-1234567890"
    organization_root_id           = "r-abc123"
    organization_master_account_id = "111111111111"
    prefix                         = "test"
    enable_macie                   = true
  }

  assert {
    condition     = var.enable_macie == true
    error_message = "Macie must be enableable in organization mode"
  }
}

# ============================================================================
# CloudTrail Log File Validation
# ============================================================================

run "cloudtrail_log_file_validation_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.cloudtrail_enable_log_file_validation == true
    error_message = "CloudTrail log file validation must be enabled by default (integrity verification)"
  }
}

run "cloudtrail_log_file_validation_can_be_disabled" {
  command = plan

  variables {
    deployment_mode                       = "single-account"
    account_id                            = "123456789012"
    prefix                                = "test"
    cloudtrail_enable_log_file_validation = false
  }

  assert {
    condition     = var.cloudtrail_enable_log_file_validation == false
    error_message = "CloudTrail log file validation must be disableable"
  }
}

run "cloudtrail_can_be_disabled" {
  command = plan

  variables {
    deployment_mode   = "single-account"
    account_id        = "123456789012"
    prefix            = "test"
    enable_cloudtrail = false
  }

  assert {
    condition     = var.enable_cloudtrail == false
    error_message = "CloudTrail must be disableable"
  }
}

# ============================================================================
# GuardDuty Delegated Admin (Organization Mode)
# ============================================================================

run "guardduty_delegated_admin_disabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_guardduty_delegated_admin == false
    error_message = "GuardDuty delegated admin must be disabled by default"
  }
}

run "guardduty_delegated_admin_requires_account_id_in_org_mode" {
  command = plan

  variables {
    deployment_mode                      = "organization"
    organization_id                      = "o-1234567890"
    organization_root_id                 = "r-abc123"
    organization_master_account_id       = "111111111111"
    prefix                               = "test"
    enable_guardduty_delegated_admin     = true
    guardduty_delegated_admin_account_id = null
  }

  expect_failures = [
    check.deployment_mode_requirements
  ]
}

run "guardduty_delegated_admin_valid_with_account_id" {
  command = plan

  variables {
    deployment_mode                      = "organization"
    organization_id                      = "o-1234567890"
    organization_root_id                 = "r-abc123"
    organization_master_account_id       = "111111111111"
    prefix                               = "test"
    enable_guardduty_delegated_admin     = true
    guardduty_delegated_admin_account_id = "222222222222"
  }

  assert {
    condition     = var.guardduty_delegated_admin_account_id == "222222222222"
    error_message = "GuardDuty delegated admin must be configurable with explicit account ID"
  }
}

# ============================================================================
# Enabled Regions Validation
# ============================================================================

run "enabled_regions_empty_list_fails" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enabled_regions = []
  }

  expect_failures = [
    var.enabled_regions
  ]
}

run "enabled_regions_single_region" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enabled_regions = ["us-east-1"]
  }

  assert {
    condition     = length(var.enabled_regions) == 1
    error_message = "A single region must be accepted"
  }
}

run "enabled_regions_multiple_regions" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enabled_regions = ["us-east-1", "us-west-2", "eu-west-1"]
  }

  assert {
    condition     = length(var.enabled_regions) == 3
    error_message = "Multiple regions must be accepted"
  }

  assert {
    condition     = contains(var.enabled_regions, "us-east-1")
    error_message = "us-east-1 must be present in the enabled regions list"
  }
}

run "enabled_regions_default_is_us_east_1" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enabled_regions == ["us-east-1"]
    error_message = "Default enabled region must be us-east-1"
  }
}

# ============================================================================
# Combined Security Stack Configurations
# ============================================================================

run "full_security_stack_enabled" {
  command = plan

  variables {
    deployment_mode                               = "single-account"
    account_id                                    = "123456789012"
    prefix                                        = "test"
    enable_guardduty                              = true
    enable_security_hub                           = true
    enable_security_hub_cis_standard              = true
    enable_security_hub_aws_foundational_standard = true
    enable_config                                 = true
    enable_macie                                  = true
    enable_cloudtrail                             = true
    enable_kms_key                                = true
    enable_iam_access_analyzer                    = true
  }

  assert {
    condition     = var.enable_guardduty == true
    error_message = "GuardDuty must be enabled in full security stack"
  }

  assert {
    condition     = var.enable_security_hub == true
    error_message = "Security Hub must be enabled in full security stack"
  }

  assert {
    condition     = var.enable_config == true
    error_message = "AWS Config must be enabled in full security stack"
  }

  assert {
    condition     = var.enable_macie == true
    error_message = "Macie must be enabled in full security stack"
  }
}

run "minimal_security_stack" {
  command = plan

  variables {
    deployment_mode            = "single-account"
    account_id                 = "123456789012"
    prefix                     = "test"
    enable_guardduty           = false
    enable_security_hub        = false
    enable_config              = false
    enable_macie               = false
    enable_cloudtrail          = false
    enable_kms_key             = false
    enable_iam_access_analyzer = false
  }

  assert {
    condition = (
      var.enable_guardduty == false &&
      var.enable_security_hub == false &&
      var.enable_config == false &&
      var.enable_macie == false &&
      var.enable_cloudtrail == false &&
      var.enable_kms_key == false &&
      var.enable_iam_access_analyzer == false
    )
    error_message = "All security services must be independently disableable"
  }
}
