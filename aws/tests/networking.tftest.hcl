# ============================================================================
# Networking Configuration Tests
# ============================================================================
# Covers: VPC CIDR validation (valid and invalid), default networking values,
# NAT gateway modes (enabled/disabled, single vs multi-AZ), VPC flow logs,
# transit gateway flag, availability zone overrides, and custom CIDR classes.
# ============================================================================

# ============================================================================
# VPC CIDR Defaults and Valid Values
# ============================================================================

run "default_vpc_cidr_is_valid" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Default VPC CIDR must be a valid CIDR block"
  }

  assert {
    condition     = var.vpc_cidr == "10.0.0.0/16"
    error_message = "Default VPC CIDR must be 10.0.0.0/16"
  }
}

run "custom_vpc_cidr_class_a_private" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    vpc_cidr        = "10.16.0.0/16"
  }

  assert {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Class A private CIDR (10.x.x.x) must be accepted"
  }
}

run "custom_vpc_cidr_class_b_private" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    vpc_cidr        = "172.16.0.0/16"
  }

  assert {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Class B private CIDR (172.16.x.x) must be accepted"
  }
}

run "custom_vpc_cidr_class_c_private" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    vpc_cidr        = "192.168.1.0/24"
  }

  assert {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Class C private CIDR (192.168.x.x) must be accepted"
  }
}

run "custom_vpc_cidr_slash_24" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    vpc_cidr        = "10.0.0.0/24"
  }

  assert {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "/24 subnet mask must be accepted as a valid CIDR"
  }
}

# ============================================================================
# VPC CIDR Validation Failures
# ============================================================================

run "invalid_vpc_cidr_plain_text" {
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

run "invalid_vpc_cidr_out_of_range_octets" {
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

run "invalid_vpc_cidr_missing_prefix_length" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    vpc_cidr        = "10.0.0.0"
  }

  expect_failures = [
    var.vpc_cidr
  ]
}

# ============================================================================
# NAT Gateway Configuration
# ============================================================================

run "nat_gateway_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_nat_gateway == true
    error_message = "NAT Gateway must be enabled by default"
  }
}

run "nat_gateway_disabled" {
  command = plan

  variables {
    deployment_mode    = "single-account"
    account_id         = "123456789012"
    prefix             = "test"
    enable_nat_gateway = false
  }

  assert {
    condition     = var.enable_nat_gateway == false
    error_message = "NAT Gateway must be disableable"
  }
}

run "single_nat_gateway_mode" {
  command = plan

  variables {
    deployment_mode    = "single-account"
    account_id         = "123456789012"
    prefix             = "test"
    enable_nat_gateway = true
    single_nat_gateway = true
  }

  assert {
    condition     = var.single_nat_gateway == true
    error_message = "Single NAT gateway mode (cost optimization) must be configurable"
  }
}

run "multi_az_nat_gateway_mode" {
  command = plan

  variables {
    deployment_mode    = "single-account"
    account_id         = "123456789012"
    prefix             = "test"
    enable_nat_gateway = true
    single_nat_gateway = false
  }

  assert {
    condition     = var.single_nat_gateway == false
    error_message = "Multi-AZ NAT gateway mode (high availability) must be configurable"
  }
}

# ============================================================================
# VPC Flow Logs
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

run "vpc_flow_logs_disabled" {
  command = plan

  variables {
    deployment_mode      = "single-account"
    account_id           = "123456789012"
    prefix               = "test"
    enable_vpc_flow_logs = false
  }

  assert {
    condition     = var.enable_vpc_flow_logs == false
    error_message = "VPC Flow Logs must be disableable"
  }
}

# ============================================================================
# Transit Gateway
# ============================================================================

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

run "transit_gateway_requested_in_single_account_mode" {
  command = plan

  variables {
    deployment_mode        = "single-account"
    account_id             = "123456789012"
    prefix                 = "test"
    enable_transit_gateway = true
  }

  assert {
    condition     = var.enable_transit_gateway == true
    error_message = "Transit Gateway flag must be settable (module logic controls actual creation)"
  }
}

run "transit_gateway_enabled_in_organization_mode" {
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
    error_message = "Transit Gateway must be enableable in organization mode"
  }
}

# ============================================================================
# Availability Zone Overrides
# ============================================================================

run "custom_availability_zones_three_azs" {
  command = plan

  variables {
    deployment_mode    = "single-account"
    account_id         = "123456789012"
    prefix             = "test"
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }

  assert {
    condition     = length(var.availability_zones) == 3
    error_message = "Three explicit availability zones must be accepted"
  }
}

run "custom_availability_zones_two_azs" {
  command = plan

  variables {
    deployment_mode    = "single-account"
    account_id         = "123456789012"
    prefix             = "test"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  assert {
    condition     = length(var.availability_zones) == 2
    error_message = "Two explicit availability zones must be accepted"
  }
}

run "default_availability_zones_empty" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = length(var.availability_zones) == 0
    error_message = "Default availability zones must be an empty list (auto-discovered from provider)"
  }
}
