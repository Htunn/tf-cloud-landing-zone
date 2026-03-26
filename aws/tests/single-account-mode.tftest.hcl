# ============================================================================
# Single-Account Mode Tests
# ============================================================================
# Covers: basic configuration, deployment mode outputs, account ID validation,
# KMS window boundaries, prefix validation, security feature toggles,
# region configuration, and organization output suppression.
# ============================================================================

# ============================================================================
# Basic Configuration
# ============================================================================

run "validate_single_account_mode_basic" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enabled_regions = ["us-east-1"]
    vpc_cidr        = "10.0.0.0/16"
  }

  assert {
    condition     = var.deployment_mode == "single-account"
    error_message = "Deployment mode should be single-account"
  }

  assert {
    condition     = var.account_id == "123456789012"
    error_message = "Account ID should match input"
  }
}

run "validate_single_account_requires_account_id" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = null
    prefix          = "test"
  }

  expect_failures = [
    check.deployment_mode_requirements
  ]
}

run "validate_vpc_cidr" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    vpc_cidr        = "10.0.0.0/16"
  }

  assert {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR should be valid"
  }
}

run "validate_prefix_format" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "Invalid_Prefix!"
  }

  expect_failures = [
    var.prefix
  ]
}

# ============================================================================
# Deployment Mode Output
# ============================================================================

run "deployment_mode_output_reflects_input" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = output.deployment_mode == "single-account"
    error_message = "deployment_mode output must reflect the input variable value"
  }
}

run "organization_output_is_null_in_single_account_mode" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = output.organization == null
    error_message = "organization output must be null when not in organization mode"
  }
}

# ============================================================================
# Account ID Validation
# ============================================================================

run "account_id_invalid_contains_letters" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "12345678901a"
    prefix          = "test"
  }

  expect_failures = [
    var.account_id
  ]
}

run "account_id_invalid_eleven_digits" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "12345678901"
    prefix          = "test"
  }

  expect_failures = [
    var.account_id
  ]
}

run "account_id_invalid_thirteen_digits" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "1234567890123"
    prefix          = "test"
  }

  expect_failures = [
    var.account_id
  ]
}

run "account_id_valid_twelve_digits" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "999999999999"
    prefix          = "test"
  }

  assert {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "Any valid 12-digit numeric account ID must be accepted"
  }
}

# ============================================================================
# KMS Configuration Boundary Tests
# ============================================================================

run "kms_deletion_window_boundary_minimum_valid" {
  command = plan

  variables {
    deployment_mode                 = "single-account"
    account_id                      = "123456789012"
    prefix                          = "test"
    kms_key_deletion_window_in_days = 7
  }

  assert {
    condition     = var.kms_key_deletion_window_in_days == 7
    error_message = "Minimum KMS deletion window of 7 days must be accepted"
  }
}

run "kms_deletion_window_boundary_maximum_valid" {
  command = plan

  variables {
    deployment_mode                 = "single-account"
    account_id                      = "123456789012"
    prefix                          = "test"
    kms_key_deletion_window_in_days = 30
  }

  assert {
    condition     = var.kms_key_deletion_window_in_days == 30
    error_message = "Maximum KMS deletion window of 30 days must be accepted"
  }
}

# ============================================================================
# Prefix Validation
# ============================================================================

run "prefix_with_uppercase_invalid" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "MyLandingZone"
  }

  expect_failures = [
    var.prefix
  ]
}

run "prefix_with_underscores_invalid" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "my_landing_zone"
  }

  expect_failures = [
    var.prefix
  ]
}

run "prefix_alphanumeric_and_hyphens_valid" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "my-lz-01"
  }

  assert {
    condition     = can(regex("^[a-z0-9-]+$", var.prefix))
    error_message = "Prefix with lowercase letters, numbers, and hyphens must be accepted"
  }
}

# ============================================================================
# Security Service Feature Toggles
# ============================================================================

run "all_security_services_disabled" {
  command = plan

  variables {
    deployment_mode     = "single-account"
    account_id          = "123456789012"
    prefix              = "test"
    enable_guardduty    = false
    enable_security_hub = false
    enable_config       = false
    enable_macie        = false
  }

  assert {
    condition     = var.enable_guardduty == false
    error_message = "GuardDuty must be disableable"
  }

  assert {
    condition     = var.enable_security_hub == false
    error_message = "Security Hub must be disableable"
  }

  assert {
    condition     = var.enable_config == false
    error_message = "AWS Config must be disableable"
  }

  assert {
    condition     = var.enable_macie == false
    error_message = "Macie must be disableable"
  }
}

run "macie_enabled_single_account" {
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

# ============================================================================
# Region Configuration
# ============================================================================

run "multiple_enabled_regions" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enabled_regions = ["us-east-1", "us-west-2", "eu-west-1"]
  }

  assert {
    condition     = length(var.enabled_regions) == 3
    error_message = "Multiple enabled regions must be supported"
  }

  assert {
    condition     = contains(var.enabled_regions, "us-east-1")
    error_message = "us-east-1 should be in the enabled regions list"
  }
}
