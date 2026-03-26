# ============================================================================
# Organization Mode Tests
# ============================================================================
# Covers: basic org mode configuration, required field validation, org ID
# format rules, transit gateway, GuardDuty delegated admin, cross-account
# roles, organizational units, service control policies, and output assertions.
# ============================================================================

# ============================================================================
# Basic Configuration
# ============================================================================

run "validate_organization_mode_basic" {
  command = plan

  variables {
    deployment_mode                = "organization"
    organization_id                = "o-1234567890"
    organization_root_id           = "r-abc123"
    organization_master_account_id = "111111111111"
    prefix                         = "test"
    enabled_regions                = ["us-east-1"]
    vpc_cidr                       = "10.0.0.0/16"

    organizational_units = {
      production = {
        name      = "Production"
        parent_id = "r-abc123"
      }
    }
  }

  assert {
    condition     = var.deployment_mode == "organization"
    error_message = "Deployment mode should be organization"
  }

  assert {
    condition     = var.organization_id == "o-1234567890"
    error_message = "Organization ID should match input"
  }
}

run "validate_organization_requires_org_id" {
  command = plan

  variables {
    deployment_mode      = "organization"
    organization_id      = null
    organization_root_id = "r-abc123"
    prefix               = "test"
  }

  expect_failures = [
    check.deployment_mode_requirements
  ]
}

run "validate_organization_requires_root_id" {
  command = plan

  variables {
    deployment_mode      = "organization"
    organization_id      = "o-1234567890"
    organization_root_id = null
    prefix               = "test"
  }

  expect_failures = [
    check.deployment_mode_requirements
  ]
}

run "validate_organization_id_format" {
  command = plan

  variables {
    deployment_mode      = "organization"
    organization_id      = "invalid-org-id"
    organization_root_id = "r-abc123"
    prefix               = "test"
  }

  expect_failures = [
    var.organization_id
  ]
}

# ============================================================================
# Deployment Mode Output
# ============================================================================

run "deployment_mode_output_reflects_organization" {
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
    error_message = "deployment_mode output must reflect organization mode"
  }
}

run "account_output_is_null_in_organization_mode" {
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
    error_message = "account output must be null when not in single-account mode"
  }
}

# ============================================================================
# Organization ID Format Validation
# ============================================================================

run "org_id_format_nine_chars_invalid" {
  command = plan

  variables {
    deployment_mode      = "organization"
    organization_id      = "o-123456789"
    organization_root_id = "r-abc123"
    prefix               = "test"
  }

  expect_failures = [
    var.organization_id
  ]
}

run "org_id_format_minimum_length_valid" {
  command = plan

  variables {
    deployment_mode      = "organization"
    organization_id      = "o-1234567890"
    organization_root_id = "r-abc123"
    prefix               = "test"
  }

  assert {
    condition     = can(regex("^o-[a-z0-9]{10,32}$", var.organization_id))
    error_message = "Organization ID with minimum 10-char suffix must be valid"
  }
}

run "org_id_format_long_valid" {
  command = plan

  variables {
    deployment_mode      = "organization"
    organization_id      = "o-abcdef1234567890abcdef123456"
    organization_root_id = "r-abc123"
    prefix               = "test"
  }

  assert {
    condition     = can(regex("^o-[a-z0-9]{10,32}$", var.organization_id))
    error_message = "Longer organization ID should be accepted within 32-char limit"
  }
}

# ============================================================================
# Transit Gateway
# ============================================================================

run "org_mode_transit_gateway_enabled" {
  command = plan

  variables {
    deployment_mode                = "organization"
    organization_id                = "o-1234567890"
    organization_root_id           = "r-abc123"
    organization_master_account_id = "111111111111"
    prefix                         = "test"
    enable_transit_gateway         = true
  }

  assert {
    condition     = var.enable_transit_gateway == true
    error_message = "Transit Gateway must be configurable in organization mode"
  }
}

# ============================================================================
# GuardDuty Delegated Admin
# ============================================================================

run "org_mode_guardduty_delegated_admin_valid" {
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
    condition     = var.enable_guardduty_delegated_admin == true
    error_message = "GuardDuty delegated admin must be enabled when account ID is provided"
  }

  assert {
    condition     = var.guardduty_delegated_admin_account_id == "222222222222"
    error_message = "GuardDuty delegated admin account ID must match input"
  }
}

# ============================================================================
# Cross-Account Roles
# ============================================================================

run "org_mode_cross_account_roles_enabled" {
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
    error_message = "Cross-account IAM roles must be configurable in organization mode"
  }
}

# ============================================================================
# Organizational Units
# ============================================================================

run "org_mode_multiple_organizational_units" {
  command = plan

  variables {
    deployment_mode                = "organization"
    organization_id                = "o-1234567890"
    organization_root_id           = "r-abc123"
    organization_master_account_id = "111111111111"
    prefix                         = "test"

    organizational_units = {
      production = {
        name      = "Production"
        parent_id = "r-abc123"
      }
      development = {
        name      = "Development"
        parent_id = "r-abc123"
      }
      sandbox = {
        name      = "Sandbox"
        parent_id = "r-abc123"
      }
    }
  }

  assert {
    condition     = length(var.organizational_units) == 3
    error_message = "Three organizational units must be accepted"
  }

  assert {
    condition     = contains(keys(var.organizational_units), "production")
    error_message = "Production OU must be present in the map"
  }

  assert {
    condition     = contains(keys(var.organizational_units), "development")
    error_message = "Development OU must be present in the map"
  }

  assert {
    condition     = contains(keys(var.organizational_units), "sandbox")
    error_message = "Sandbox OU must be present in the map"
  }
}

# ============================================================================
# Service Control Policies
# ============================================================================

run "org_mode_with_service_control_policy" {
  command = plan

  variables {
    deployment_mode                = "organization"
    organization_id                = "o-1234567890"
    organization_root_id           = "r-abc123"
    organization_master_account_id = "111111111111"
    prefix                         = "test"

    service_control_policies = {
      deny_region = {
        name        = "DenyNonApprovedRegions"
        description = "Deny access to non-approved AWS regions"
        content     = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Action\":\"*\",\"Resource\":\"*\",\"Condition\":{\"StringNotEquals\":{\"aws:RequestedRegion\":[\"us-east-1\"]}}}]}"
        targets     = ["r-abc123"]
      }
    }
  }

  assert {
    condition     = length(var.service_control_policies) == 1
    error_message = "Service control policy configuration must be accepted"
  }

  assert {
    condition     = contains(keys(var.service_control_policies), "deny_region")
    error_message = "deny_region SCP must be present in the map"
  }
}

run "org_mode_multiple_service_control_policies" {
  command = plan

  variables {
    deployment_mode                = "organization"
    organization_id                = "o-1234567890"
    organization_root_id           = "r-abc123"
    organization_master_account_id = "111111111111"
    prefix                         = "test"

    service_control_policies = {
      deny_region = {
        name        = "DenyNonApprovedRegions"
        description = "Restrict to approved regions"
        content     = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Action\":\"*\",\"Resource\":\"*\"}]}"
        targets     = ["r-abc123"]
      }
      require_mfa = {
        name        = "RequireMFA"
        description = "Require MFA for all actions"
        content     = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Action\":\"*\",\"Resource\":\"*\",\"Condition\":{\"Bool\":{\"aws:MultiFactorAuthPresent\":\"false\"}}}]}"
        targets     = ["r-abc123"]
      }
    }
  }

  assert {
    condition     = length(var.service_control_policies) == 2
    error_message = "Multiple SCPs must be accepted"
  }
}

# ============================================================================
# Security Services in Organization Mode
# ============================================================================

run "org_mode_all_security_services_enabled" {
  command = plan

  variables {
    deployment_mode                = "organization"
    organization_id                = "o-1234567890"
    organization_root_id           = "r-abc123"
    organization_master_account_id = "111111111111"
    prefix                         = "test"
    enable_guardduty               = true
    enable_security_hub            = true
    enable_config                  = true
    enable_macie                   = true
  }

  assert {
    condition     = var.enable_guardduty == true
    error_message = "GuardDuty must be enableable in organization mode"
  }

  assert {
    condition     = var.enable_macie == true
    error_message = "Macie must be enableable in organization mode"
  }
}
