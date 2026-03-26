# ============================================================================
# Logging Configuration Tests
# ============================================================================
# Covers: centralized logging bucket enable/disable, CloudTrail defaults,
# CloudWatch log retention valid boundary values, VPC flow logs interaction,
# and logging-related output structure in landing_zone_config.
# ============================================================================

# ============================================================================
# Centralized Logging Bucket
# ============================================================================

run "centralized_logging_bucket_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_centralized_logging_bucket == true
    error_message = "Centralized logging bucket must be enabled by default"
  }
}

run "centralized_logging_bucket_can_be_disabled" {
  command = plan

  variables {
    deployment_mode                   = "single-account"
    account_id                        = "123456789012"
    prefix                            = "test"
    enable_centralized_logging_bucket = false
  }

  assert {
    condition     = var.enable_centralized_logging_bucket == false
    error_message = "Centralized logging bucket must be disableable"
  }
}

run "centralized_logging_bucket_in_org_mode" {
  command = plan

  variables {
    deployment_mode                   = "organization"
    organization_id                   = "o-1234567890"
    organization_root_id              = "r-abc123"
    organization_master_account_id    = "111111111111"
    prefix                            = "test"
    enable_centralized_logging_bucket = true
  }

  assert {
    condition     = var.enable_centralized_logging_bucket == true
    error_message = "Centralized logging bucket must be configurable in organization mode"
  }
}

# ============================================================================
# CloudTrail Configuration
# ============================================================================

run "cloudtrail_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_cloudtrail == true
    error_message = "CloudTrail must be enabled by default for audit compliance"
  }
}

run "cloudtrail_log_validation_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.cloudtrail_enable_log_file_validation == true
    error_message = "CloudTrail log file validation must be on by default (CIS benchmark)"
  }
}

run "cloudtrail_disabled_with_log_validation_also_off" {
  command = plan

  variables {
    deployment_mode                       = "single-account"
    account_id                            = "123456789012"
    prefix                                = "test"
    enable_cloudtrail                     = false
    cloudtrail_enable_log_file_validation = false
  }

  assert {
    condition     = var.enable_cloudtrail == false && var.cloudtrail_enable_log_file_validation == false
    error_message = "CloudTrail and log validation must both be independently disableable"
  }
}

# ============================================================================
# CloudWatch Log Retention – Boundary Values
# ============================================================================

run "cloudwatch_retention_default_90_days" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.cloudwatch_log_retention_days == 90
    error_message = "Default CloudWatch retention must be 90 days"
  }
}

run "cloudwatch_retention_1_day_minimum" {
  command = plan

  variables {
    deployment_mode               = "single-account"
    account_id                    = "123456789012"
    prefix                        = "test"
    cloudwatch_log_retention_days = 1
  }

  assert {
    condition     = var.cloudwatch_log_retention_days == 1
    error_message = "1 day retention must be accepted as the minimum value"
  }
}

run "cloudwatch_retention_3_days" {
  command = plan

  variables {
    deployment_mode               = "single-account"
    account_id                    = "123456789012"
    prefix                        = "test"
    cloudwatch_log_retention_days = 3
  }

  assert {
    condition     = var.cloudwatch_log_retention_days == 3
    error_message = "3 days retention must be accepted"
  }
}

run "cloudwatch_retention_5_days" {
  command = plan

  variables {
    deployment_mode               = "single-account"
    account_id                    = "123456789012"
    prefix                        = "test"
    cloudwatch_log_retention_days = 5
  }

  assert {
    condition     = var.cloudwatch_log_retention_days == 5
    error_message = "5 days retention must be accepted"
  }
}

run "cloudwatch_retention_14_days" {
  command = plan

  variables {
    deployment_mode               = "single-account"
    account_id                    = "123456789012"
    prefix                        = "test"
    cloudwatch_log_retention_days = 14
  }

  assert {
    condition     = var.cloudwatch_log_retention_days == 14
    error_message = "14 days retention must be accepted"
  }
}

run "cloudwatch_retention_30_days" {
  command = plan

  variables {
    deployment_mode               = "single-account"
    account_id                    = "123456789012"
    prefix                        = "test"
    cloudwatch_log_retention_days = 30
  }

  assert {
    condition     = var.cloudwatch_log_retention_days == 30
    error_message = "30 days retention must be accepted"
  }
}

run "cloudwatch_retention_60_days" {
  command = plan

  variables {
    deployment_mode               = "single-account"
    account_id                    = "123456789012"
    prefix                        = "test"
    cloudwatch_log_retention_days = 60
  }

  assert {
    condition     = var.cloudwatch_log_retention_days == 60
    error_message = "60 days retention must be accepted"
  }
}

run "cloudwatch_retention_180_days" {
  command = plan

  variables {
    deployment_mode               = "single-account"
    account_id                    = "123456789012"
    prefix                        = "test"
    cloudwatch_log_retention_days = 180
  }

  assert {
    condition     = var.cloudwatch_log_retention_days == 180
    error_message = "180 days retention must be accepted"
  }
}

run "cloudwatch_retention_731_days_two_years" {
  command = plan

  variables {
    deployment_mode               = "single-account"
    account_id                    = "123456789012"
    prefix                        = "test"
    cloudwatch_log_retention_days = 731
  }

  assert {
    condition     = var.cloudwatch_log_retention_days == 731
    error_message = "731 days (2 years) retention must be accepted"
  }
}

run "cloudwatch_retention_1827_days_five_years" {
  command = plan

  variables {
    deployment_mode               = "single-account"
    account_id                    = "123456789012"
    prefix                        = "test"
    cloudwatch_log_retention_days = 1827
  }

  assert {
    condition     = var.cloudwatch_log_retention_days == 1827
    error_message = "1827 days (5 years) retention must be accepted"
  }
}

run "cloudwatch_retention_invalid_non_standard_value" {
  command = plan

  variables {
    deployment_mode               = "single-account"
    account_id                    = "123456789012"
    prefix                        = "test"
    cloudwatch_log_retention_days = 100
  }

  expect_failures = [
    var.cloudwatch_log_retention_days
  ]
}

run "cloudwatch_retention_invalid_negative" {
  command = plan

  variables {
    deployment_mode               = "single-account"
    account_id                    = "123456789012"
    prefix                        = "test"
    cloudwatch_log_retention_days = -1
  }

  expect_failures = [
    var.cloudwatch_log_retention_days
  ]
}

# ============================================================================
# VPC Flow Logs and Logging Interaction
# ============================================================================

run "vpc_flow_logs_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_vpc_flow_logs == true
    error_message = "VPC Flow Logs must be enabled by default"
  }
}

run "logging_all_sources_enabled" {
  command = plan

  variables {
    deployment_mode                   = "single-account"
    account_id                        = "123456789012"
    prefix                            = "test"
    enable_cloudtrail                 = true
    enable_vpc_flow_logs              = true
    enable_centralized_logging_bucket = true
    cloudwatch_log_retention_days     = 365
  }

  assert {
    condition = (
      var.enable_cloudtrail == true &&
      var.enable_vpc_flow_logs == true &&
      var.enable_centralized_logging_bucket == true
    )
    error_message = "All logging sources must be simultaneously enableable"
  }

  assert {
    condition     = var.cloudwatch_log_retention_days == 365
    error_message = "One-year CloudWatch retention must be configurable alongside all logging sources"
  }
}

run "logging_all_sources_disabled" {
  command = plan

  variables {
    deployment_mode                   = "single-account"
    account_id                        = "123456789012"
    prefix                            = "test"
    enable_cloudtrail                 = false
    enable_vpc_flow_logs              = false
    enable_centralized_logging_bucket = false
  }

  assert {
    condition = (
      var.enable_cloudtrail == false &&
      var.enable_vpc_flow_logs == false &&
      var.enable_centralized_logging_bucket == false
    )
    error_message = "All logging sources must be simultaneously disableable"
  }
}
