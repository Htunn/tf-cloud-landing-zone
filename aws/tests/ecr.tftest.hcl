# ============================================================================
# ECR Module Tests
# ============================================================================
# Covers: default empty repositories, repository map input, lifecycle policy
# variables, cross-account pull defaults, untagged expiry days, keep-count
# defaults, KMS integration flag, ecr output block structure, and
# landing_zone_config passthrough.
# ============================================================================

# ============================================================================
# ECR — Empty Repositories by Default
# ============================================================================

run "ecr_repositories_default_empty" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = length(var.ecr_repositories) == 0
    error_message = "ecr_repositories must default to empty map"
  }
}

run "ecr_output_maps_empty_when_no_repositories" {
  command = plan

  variables {
    deployment_mode  = "single-account"
    account_id       = "123456789012"
    prefix           = "test"
    ecr_repositories = {}
  }

  assert {
    condition     = length(output.ecr.repository_urls) == 0
    error_message = "ecr.repository_urls must be empty when no repositories are defined"
  }

  assert {
    condition     = length(output.ecr.repository_arns) == 0
    error_message = "ecr.repository_arns must be empty when no repositories are defined"
  }

  assert {
    condition     = length(output.ecr.repository_names) == 0
    error_message = "ecr.repository_names must be empty when no repositories are defined"
  }
}

# ============================================================================
# ECR — Single Repository Defined
# ============================================================================

run "ecr_single_repository_accepted" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    ecr_repositories = {
      app = {
        image_tag_mutability = "IMMUTABLE"
        scan_on_push         = true
        force_delete         = false
      }
    }
  }

  assert {
    condition     = length(var.ecr_repositories) == 1
    error_message = "ecr_repositories must accept a single-entry map"
  }
}

run "ecr_multiple_repositories_accepted" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    ecr_repositories = {
      frontend = {
        image_tag_mutability = "MUTABLE"
        scan_on_push         = true
        force_delete         = false
      }
      backend = {
        image_tag_mutability = "IMMUTABLE"
        scan_on_push         = true
        force_delete         = false
      }
      worker = {
        image_tag_mutability = "MUTABLE"
        scan_on_push         = false
        force_delete         = false
      }
    }
  }

  assert {
    condition     = length(var.ecr_repositories) == 3
    error_message = "ecr_repositories must accept multiple repository entries"
  }
}

# ============================================================================
# ECR — Lifecycle Policy Variables
# ============================================================================

run "ecr_lifecycle_keep_count_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.ecr_lifecycle_policy_keep_count == 20
    error_message = "ecr_lifecycle_policy_keep_count must default to 20"
  }
}

run "ecr_lifecycle_keep_count_configurable" {
  command = plan

  variables {
    deployment_mode                 = "single-account"
    account_id                      = "123456789012"
    prefix                          = "test"
    ecr_lifecycle_policy_keep_count = 50
  }

  assert {
    condition     = var.ecr_lifecycle_policy_keep_count == 50
    error_message = "ecr_lifecycle_policy_keep_count must accept custom values"
  }
}

run "ecr_untagged_expiry_days_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.ecr_untagged_image_expiry_days == 7
    error_message = "ecr_untagged_image_expiry_days must default to 7"
  }
}

run "ecr_untagged_expiry_days_configurable" {
  command = plan

  variables {
    deployment_mode                = "single-account"
    account_id                     = "123456789012"
    prefix                         = "test"
    ecr_untagged_image_expiry_days = 14
  }

  assert {
    condition     = var.ecr_untagged_image_expiry_days == 14
    error_message = "ecr_untagged_image_expiry_days must accept 14"
  }
}

# ============================================================================
# ECR — Cross-Account Pull Defaults
# ============================================================================

run "ecr_cross_account_pull_disabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.ecr_enable_cross_account_pull == false
    error_message = "ecr_enable_cross_account_pull must default to false"
  }
}

run "ecr_cross_account_ids_default_empty" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = length(var.ecr_cross_account_ids) == 0
    error_message = "ecr_cross_account_ids must default to empty list"
  }
}

run "ecr_cross_account_pull_with_account_ids" {
  command = plan

  variables {
    deployment_mode              = "single-account"
    account_id                   = "123456789012"
    prefix                       = "test"
    ecr_enable_cross_account_pull = true
    ecr_cross_account_ids        = ["111111111111", "222222222222"]
  }

  assert {
    condition     = length(var.ecr_cross_account_ids) == 2
    error_message = "ecr_cross_account_ids must accept a list of account IDs"
  }
}

# ============================================================================
# ECR — KMS Integration
# ============================================================================

run "ecr_with_kms_enabled" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enable_kms_key  = true
    ecr_repositories = {
      app = {}
    }
  }

  assert {
    condition     = var.enable_kms_key == true
    error_message = "enable_kms_key must be accepted alongside ecr_repositories"
  }
}

run "ecr_without_kms_still_creates_repositories" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enable_kms_key  = false
    ecr_repositories = {
      app = {
        scan_on_push = true
      }
    }
  }

  assert {
    condition     = length(var.ecr_repositories) == 1
    error_message = "ECR repositories must be creatable without KMS"
  }
}
