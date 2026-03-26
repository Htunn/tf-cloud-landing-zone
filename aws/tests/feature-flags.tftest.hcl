# ============================================================================
# Feature Flag Tests
# ============================================================================
# Covers: KMS key output nullability, conditional output values based on mode,
# GuardDuty finding frequency valid values, CloudWatch retention valid values,
# security service defaults, and cross-cutting feature toggle combinations.
# ============================================================================

# ============================================================================
# KMS Key Output Nullability
# ============================================================================

run "kms_key_outputs_null_when_disabled" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enable_kms_key  = false
  }

  assert {
    condition     = output.kms_key_id == null
    error_message = "kms_key_id must be null when enable_kms_key is false"
  }

  assert {
    condition     = output.kms_key_arn == null
    error_message = "kms_key_arn must be null when enable_kms_key is false"
  }
}

# ============================================================================
# Mode-Conditional Output Suppression
# ============================================================================

run "organization_output_null_in_single_account_mode" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = output.organization == null
    error_message = "organization output must be null when deployment_mode is single-account"
  }
}

run "account_output_null_in_organization_mode" {
  command = plan

  variables {
    deployment_mode                = "organization"
    organization_id                = "o-1234567890"
    organization_root_id           = "r-abc123"
    organization_master_account_id = "111111111111"
    prefix                         = "test"
  }

  assert {
    condition     = output.account == null
    error_message = "account output must be null when deployment_mode is organization"
  }
}

run "deployment_mode_output_single_account" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = output.deployment_mode == "single-account"
    error_message = "deployment_mode output must equal the input variable value"
  }
}

run "deployment_mode_output_organization" {
  command = plan

  variables {
    deployment_mode                = "organization"
    organization_id                = "o-1234567890"
    organization_root_id           = "r-abc123"
    organization_master_account_id = "111111111111"
    prefix                         = "test"
  }

  assert {
    condition     = output.deployment_mode == "organization"
    error_message = "deployment_mode output must equal the input variable value"
  }
}

# ============================================================================
# GuardDuty Finding Publishing Frequency – All Valid Values
# ============================================================================

run "finding_frequency_fifteen_minutes_valid" {
  command = plan

  variables {
    deployment_mode                        = "single-account"
    account_id                             = "123456789012"
    prefix                                 = "test"
    guardduty_finding_publishing_frequency = "FIFTEEN_MINUTES"
  }

  assert {
    condition     = var.guardduty_finding_publishing_frequency == "FIFTEEN_MINUTES"
    error_message = "FIFTEEN_MINUTES must be accepted as a valid finding frequency"
  }
}

run "finding_frequency_one_hour_valid" {
  command = plan

  variables {
    deployment_mode                        = "single-account"
    account_id                             = "123456789012"
    prefix                                 = "test"
    guardduty_finding_publishing_frequency = "ONE_HOUR"
  }

  assert {
    condition     = var.guardduty_finding_publishing_frequency == "ONE_HOUR"
    error_message = "ONE_HOUR must be accepted as a valid finding frequency"
  }
}

run "finding_frequency_six_hours_valid" {
  command = plan

  variables {
    deployment_mode                        = "single-account"
    account_id                             = "123456789012"
    prefix                                 = "test"
    guardduty_finding_publishing_frequency = "SIX_HOURS"
  }

  assert {
    condition     = var.guardduty_finding_publishing_frequency == "SIX_HOURS"
    error_message = "SIX_HOURS must be accepted as a valid finding frequency"
  }
}

# ============================================================================
# CloudWatch Log Retention – Boundary Valid Values
# ============================================================================

run "cloudwatch_retention_zero_unlimited" {
  command = plan

  variables {
    deployment_mode               = "single-account"
    account_id                    = "123456789012"
    prefix                        = "test"
    cloudwatch_log_retention_days = 0
  }

  assert {
    condition     = var.cloudwatch_log_retention_days == 0
    error_message = "0 (unlimited retention) must be accepted"
  }
}

run "cloudwatch_retention_365_days" {
  command = plan

  variables {
    deployment_mode               = "single-account"
    account_id                    = "123456789012"
    prefix                        = "test"
    cloudwatch_log_retention_days = 365
  }

  assert {
    condition     = var.cloudwatch_log_retention_days == 365
    error_message = "365 days must be accepted as a valid retention period"
  }
}

run "cloudwatch_retention_3653_days_maximum" {
  command = plan

  variables {
    deployment_mode               = "single-account"
    account_id                    = "123456789012"
    prefix                        = "test"
    cloudwatch_log_retention_days = 3653
  }

  assert {
    condition     = var.cloudwatch_log_retention_days == 3653
    error_message = "3653 days (10 years) must be accepted as the maximum retention period"
  }
}

# ============================================================================
# Security Service Default State
# ============================================================================

run "guardduty_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_guardduty == true
    error_message = "GuardDuty must be enabled by default"
  }
}

run "security_hub_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_security_hub == true
    error_message = "Security Hub must be enabled by default"
  }
}

run "config_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_config == true
    error_message = "AWS Config must be enabled by default"
  }
}

run "macie_disabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_macie == false
    error_message = "Macie must be disabled by default (cost consideration)"
  }
}

run "transit_gateway_disabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_transit_gateway == false
    error_message = "Transit Gateway must be disabled by default"
  }
}

run "kms_key_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_kms_key == true
    error_message = "KMS key must be enabled by default"
  }
}

run "cloudtrail_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_cloudtrail == true
    error_message = "CloudTrail must be enabled by default"
  }
}
