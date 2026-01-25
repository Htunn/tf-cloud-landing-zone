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
