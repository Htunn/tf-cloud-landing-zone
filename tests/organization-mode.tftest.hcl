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
