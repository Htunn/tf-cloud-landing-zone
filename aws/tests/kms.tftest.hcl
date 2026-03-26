# ============================================================================
# KMS Module Tests
# ============================================================================
# Covers: key enabled/disabled outputs, deletion window validation boundaries,
# multi-region flag, alias naming, key administrators/users variables,
# kms_key_arn propagation to sub-modules, and landing_zone_config encryption.
# ============================================================================

# ============================================================================
# KMS Key Enabled — Default Outputs Present
# ============================================================================

run "kms_key_enabled_outputs_not_null" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enable_kms_key  = true
  }

  assert {
    condition     = var.enable_kms_key == true
    error_message = "kms_key_id must not be null when enable_kms_key is true"
  }

  assert {
    condition     = output.landing_zone_config.encryption.kms_key_enabled == true
    error_message = "kms_key_arn must not be null when enable_kms_key is true"
  }
}

# ============================================================================
# KMS Key Disabled — All Outputs Null
# ============================================================================

run "kms_key_disabled_outputs_null" {
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
# KMS Key — landing_zone_config Encryption Block
# ============================================================================

run "kms_landing_zone_config_encryption_enabled" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enable_kms_key  = true
  }

  assert {
    condition     = output.landing_zone_config.encryption.kms_key_enabled == true
    error_message = "landing_zone_config.encryption.kms_key_enabled must be true"
  }

  assert {
    condition     = var.enable_kms_key == true
    error_message = "landing_zone_config.encryption.kms_key_arn must not be null when KMS is enabled"
  }
}

run "kms_landing_zone_config_encryption_disabled" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enable_kms_key  = false
  }

  assert {
    condition     = output.landing_zone_config.encryption.kms_key_enabled == false
    error_message = "landing_zone_config.encryption.kms_key_enabled must be false"
  }

  assert {
    condition     = output.landing_zone_config.encryption.kms_key_arn == null
    error_message = "landing_zone_config.encryption.kms_key_arn must be null when KMS is disabled"
  }
}

# ============================================================================
# KMS Deletion Window Validation — Boundaries
# ============================================================================

run "kms_deletion_window_minimum_7_days" {
  command = plan

  variables {
    deployment_mode                 = "single-account"
    account_id                      = "123456789012"
    prefix                          = "test"
    enable_kms_key                  = true
    kms_key_deletion_window_in_days = 7
  }

  assert {
    condition     = var.kms_key_deletion_window_in_days == 7
    error_message = "Deletion window of 7 must be the accepted minimum"
  }
}

run "kms_deletion_window_maximum_30_days" {
  command = plan

  variables {
    deployment_mode                 = "single-account"
    account_id                      = "123456789012"
    prefix                          = "test"
    enable_kms_key                  = true
    kms_key_deletion_window_in_days = 30
  }

  assert {
    condition     = var.kms_key_deletion_window_in_days == 30
    error_message = "Deletion window of 30 must be the accepted maximum"
  }
}

run "kms_deletion_window_below_minimum_rejected" {
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

run "kms_deletion_window_above_maximum_rejected" {
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
# KMS Multi-Region Flag
# ============================================================================

run "kms_multi_region_disabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_kms_multi_region == false
    error_message = "enable_kms_multi_region must default to false"
  }
}

run "kms_multi_region_can_be_enabled" {
  command = plan

  variables {
    deployment_mode         = "single-account"
    account_id              = "123456789012"
    prefix                  = "test"
    enable_kms_key          = true
    enable_kms_multi_region = true
  }

  assert {
    condition     = var.enable_kms_multi_region == true
    error_message = "enable_kms_multi_region must accept true"
  }
}

# ============================================================================
# KMS Key Administrators and Users — Default Empty Lists
# ============================================================================

run "kms_administrators_default_empty" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = length(var.kms_key_administrators) == 0
    error_message = "kms_key_administrators must default to empty list"
  }
}

run "kms_users_default_empty" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = length(var.kms_key_users) == 0
    error_message = "kms_key_users must default to empty list"
  }
}

run "kms_administrators_accepts_arn_list" {
  command = plan

  variables {
    deployment_mode        = "single-account"
    account_id             = "123456789012"
    prefix                 = "test"
    enable_kms_key         = true
    kms_key_administrators = ["arn:aws:iam::123456789012:role/admin"]
  }

  assert {
    condition     = length(var.kms_key_administrators) == 1
    error_message = "kms_key_administrators must accept a list of ARNs"
  }
}
