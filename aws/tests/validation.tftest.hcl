# ============================================================================
# Variable and Check Block Validation Tests
# ============================================================================
# Covers: deployment_mode enum, account_id format, organization_id format,
# organization check block assertions, KMS window bounds, GuardDuty finding
# frequency enum, CloudWatch retention valid values, VPC CIDR format,
# prefix regex, and enabled_regions minimum length.
# ============================================================================

# ============================================================================
# Check Block: deployment_mode_requirements
# ============================================================================

run "validate_guardduty_delegated_admin_requires_account_id" {
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

# ============================================================================
# KMS Key Deletion Window (7–30 days)
# ============================================================================

run "validate_kms_key_deletion_window" {
  command = plan

  variables {
    deployment_mode                 = "single-account"
    account_id                      = "123456789012"
    prefix                          = "test"
    kms_key_deletion_window_in_days = 5
  }

  expect_failures = [
    var.kms_key_deletion_window_in_days
  ]
}

run "validate_kms_window_below_minimum" {
  command = plan

  variables {
    deployment_mode                 = "single-account"
    account_id                      = "123456789012"
    prefix                          = "test"
    kms_key_deletion_window_in_days = 6
  }

  expect_failures = [
    var.kms_key_deletion_window_in_days
  ]
}

run "validate_kms_window_above_maximum" {
  command = plan

  variables {
    deployment_mode                 = "single-account"
    account_id                      = "123456789012"
    prefix                          = "test"
    kms_key_deletion_window_in_days = 31
  }

  expect_failures = [
    var.kms_key_deletion_window_in_days
  ]
}

# ============================================================================
# GuardDuty Finding Publishing Frequency
# ============================================================================

run "validate_guardduty_finding_frequency" {
  command = plan

  variables {
    deployment_mode                        = "single-account"
    account_id                             = "123456789012"
    prefix                                 = "test"
    guardduty_finding_publishing_frequency = "INVALID"
  }

  expect_failures = [
    var.guardduty_finding_publishing_frequency
  ]
}

# ============================================================================
# CloudWatch Log Retention Days (must be in valid set)
# ============================================================================

run "validate_cloudwatch_retention_days" {
  command = plan

  variables {
    deployment_mode               = "single-account"
    account_id                    = "123456789012"
    prefix                        = "test"
    cloudwatch_log_retention_days = 45
  }

  expect_failures = [
    var.cloudwatch_log_retention_days
  ]
}

run "validate_cloudwatch_retention_non_standard_value" {
  command = plan

  variables {
    deployment_mode               = "single-account"
    account_id                    = "123456789012"
    prefix                        = "test"
    cloudwatch_log_retention_days = 200
  }

  expect_failures = [
    var.cloudwatch_log_retention_days
  ]
}

# ============================================================================
# Deployment Mode Enum Validation
# ============================================================================

run "validate_invalid_deployment_mode" {
  command = plan

  variables {
    deployment_mode = "multi-account"
    prefix          = "test"
  }

  expect_failures = [
    var.deployment_mode
  ]
}

run "validate_deployment_mode_empty_string" {
  command = plan

  variables {
    deployment_mode = ""
    prefix          = "test"
  }

  expect_failures = [
    var.deployment_mode
  ]
}

# ============================================================================
# Account ID Format (must be exactly 12 digits)
# ============================================================================

run "validate_account_id_with_letters" {
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

run "validate_account_id_eleven_digits" {
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

run "validate_account_id_thirteen_digits" {
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

# ============================================================================
# Organization ID Format (must match ^o-[a-z0-9]{10,32}$)
# ============================================================================

run "validate_org_id_nine_char_suffix_invalid" {
  command = plan

  variables {
    deployment_mode                = "organization"
    organization_id                = "o-123456789"
    organization_root_id           = "r-abc123"
    organization_master_account_id = "111111111111"
    prefix                         = "test"
  }

  expect_failures = [
    var.organization_id
  ]
}

run "validate_org_id_uppercase_suffix_invalid" {
  command = plan

  variables {
    deployment_mode                = "organization"
    organization_id                = "o-ABCDEFGHIJ"
    organization_root_id           = "r-abc123"
    organization_master_account_id = "111111111111"
    prefix                         = "test"
  }

  expect_failures = [
    var.organization_id
  ]
}

run "validate_org_id_wrong_prefix_invalid" {
  command = plan

  variables {
    deployment_mode                = "organization"
    organization_id                = "x-1234567890"
    organization_root_id           = "r-abc123"
    organization_master_account_id = "111111111111"
    prefix                         = "test"
  }

  expect_failures = [
    var.organization_id
  ]
}

# ============================================================================
# VPC CIDR Block Validation
# ============================================================================

run "validate_vpc_cidr_invalid_format" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    vpc_cidr        = "not-a-cidr"
  }

  expect_failures = [
    var.vpc_cidr
  ]
}

run "validate_vpc_cidr_out_of_range" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    vpc_cidr        = "999.0.0.0/16"
  }

  expect_failures = [
    var.vpc_cidr
  ]
}

# ============================================================================
# Prefix Validation (must match ^[a-z0-9-]+$)
# ============================================================================

run "validate_prefix_special_characters" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "my.landing.zone"
  }

  expect_failures = [
    var.prefix
  ]
}

run "validate_prefix_empty_string" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = ""
  }

  expect_failures = [
    var.prefix
  ]
}

# ============================================================================
# Enabled Regions (must have at least one entry)
# ============================================================================

run "validate_empty_enabled_regions" {
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
