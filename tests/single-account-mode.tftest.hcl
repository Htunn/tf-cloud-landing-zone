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
