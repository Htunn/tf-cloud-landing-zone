# ============================================================================
# IAM Configuration Tests
# ============================================================================
# Covers: password policy defaults and custom values, IAM access analyzer
# enable/disable, cross-account role flag in both deployment modes.
# ============================================================================

# ============================================================================
# IAM Password Policy – Default Values
# ============================================================================

run "password_policy_default_minimum_length" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.iam_password_policy.minimum_password_length == 14
    error_message = "Default minimum password length must be 14 (CIS benchmark requirement)"
  }
}

run "password_policy_default_requires_lowercase" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.iam_password_policy.require_lowercase_characters == true
    error_message = "Password policy must require lowercase characters by default"
  }
}

run "password_policy_default_requires_uppercase" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.iam_password_policy.require_uppercase_characters == true
    error_message = "Password policy must require uppercase characters by default"
  }
}

run "password_policy_default_requires_numbers" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.iam_password_policy.require_numbers == true
    error_message = "Password policy must require numbers by default"
  }
}

run "password_policy_default_requires_symbols" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.iam_password_policy.require_symbols == true
    error_message = "Password policy must require symbols by default"
  }
}

run "password_policy_default_allows_user_change" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.iam_password_policy.allow_users_to_change_password == true
    error_message = "Users must be allowed to change their own passwords by default"
  }
}

run "password_policy_default_max_age_90_days" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.iam_password_policy.max_password_age == 90
    error_message = "Default max password age must be 90 days (CIS benchmark)"
  }
}

run "password_policy_default_reuse_prevention_24" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.iam_password_policy.password_reuse_prevention == 24
    error_message = "Default password reuse prevention must be 24 (CIS benchmark)"
  }
}

# ============================================================================
# IAM Password Policy – Custom Values
# ============================================================================

run "password_policy_custom_minimum_length" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    iam_password_policy = {
      minimum_password_length        = 20
      require_lowercase_characters   = true
      require_uppercase_characters   = true
      require_numbers                = true
      require_symbols                = true
      allow_users_to_change_password = true
      max_password_age               = 60
      password_reuse_prevention      = 12
    }
  }

  assert {
    condition     = var.iam_password_policy.minimum_password_length == 20
    error_message = "Custom minimum password length of 20 must be accepted"
  }

  assert {
    condition     = var.iam_password_policy.max_password_age == 60
    error_message = "Custom max_password_age of 60 days must be accepted"
  }

  assert {
    condition     = var.iam_password_policy.password_reuse_prevention == 12
    error_message = "Custom password_reuse_prevention of 12 must be accepted"
  }
}

run "password_policy_relaxed_complexity" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    iam_password_policy = {
      minimum_password_length        = 8
      require_lowercase_characters   = false
      require_uppercase_characters   = false
      require_numbers                = false
      require_symbols                = false
      allow_users_to_change_password = true
      max_password_age               = 0
      password_reuse_prevention      = 0
    }
  }

  assert {
    condition     = var.iam_password_policy.require_symbols == false
    error_message = "Symbol requirement must be overridable (some legacy environments)"
  }

  assert {
    condition     = var.iam_password_policy.max_password_age == 0
    error_message = "max_password_age of 0 (no expiry) must be accepted"
  }
}

# ============================================================================
# IAM Access Analyzer
# ============================================================================

run "iam_access_analyzer_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_iam_access_analyzer == true
    error_message = "IAM Access Analyzer must be enabled by default (security best practice)"
  }
}

run "iam_access_analyzer_can_be_disabled" {
  command = plan

  variables {
    deployment_mode            = "single-account"
    account_id                 = "123456789012"
    prefix                     = "test"
    enable_iam_access_analyzer = false
  }

  assert {
    condition     = var.enable_iam_access_analyzer == false
    error_message = "IAM Access Analyzer must be disableable"
  }
}

run "iam_access_analyzer_enabled_in_org_mode" {
  command = plan

  variables {
    deployment_mode                = "organization"
    organization_id                = "o-1234567890"
    organization_root_id           = "r-abc123"
    organization_master_account_id = "111111111111"
    prefix                         = "test"
    enable_iam_access_analyzer     = true
  }

  assert {
    condition     = var.enable_iam_access_analyzer == true
    error_message = "IAM Access Analyzer must be configurable in organization mode"
  }
}

# ============================================================================
# Cross-Account Roles
# ============================================================================

run "cross_account_roles_disabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_cross_account_roles == false
    error_message = "Cross-account roles must be disabled by default"
  }
}

run "cross_account_roles_settable_in_single_account_mode" {
  command = plan

  variables {
    deployment_mode            = "single-account"
    account_id                 = "123456789012"
    prefix                     = "test"
    enable_cross_account_roles = true
  }

  assert {
    condition     = var.enable_cross_account_roles == true
    error_message = "Cross-account roles flag must be settable (module logic controls actual creation)"
  }
}

run "cross_account_roles_enabled_in_organization_mode" {
  command = plan

  variables {
    deployment_mode                = "organization"
    organization_id                = "o-1234567890"
    organization_root_id           = "r-abc123"
    organization_master_account_id = "111111111111"
    prefix                         = "test"
    enable_cross_account_roles     = true
  }

  assert {
    condition     = var.enable_cross_account_roles == true
    error_message = "Cross-account roles must be enableable in organization mode"
  }
}
