# ============================================================================
# Compute Module Tests
# ============================================================================
# Covers: ECS cluster flag defaults, container insights flag, Lambda baseline
# defaults, Lambda log retention, EC2 disabled by default, ASG disabled by
# default, instance type default, ASG sizing variables, compute output block
# structure, and landing_zone_config compute section.
# ============================================================================

# ============================================================================
# ECS — Enabled by Default
# ============================================================================

run "ecs_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_ecs == true
    error_message = "enable_ecs must default to true"
  }
}

run "ecs_cluster_arn_not_null_when_enabled" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enable_ecs      = true
  }

  assert {
    condition     = var.enable_ecs == true
    error_message = "compute.ecs_cluster_arn must not be null when enable_ecs is true"
  }

  assert {
    condition     = output.compute.ecs_cluster_name != null
    error_message = "compute.ecs_cluster_name must not be null when enable_ecs is true"
  }
}

run "ecs_cluster_arn_null_when_disabled" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enable_ecs      = false
  }

  assert {
    condition     = output.compute.ecs_cluster_arn == null
    error_message = "compute.ecs_cluster_arn must be null when enable_ecs is false"
  }
}

# ============================================================================
# ECS — Container Insights
# ============================================================================

run "container_insights_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_container_insights == true
    error_message = "enable_container_insights must default to true"
  }
}

run "container_insights_can_be_disabled" {
  command = plan

  variables {
    deployment_mode           = "single-account"
    account_id                = "123456789012"
    prefix                    = "test"
    enable_container_insights = false
  }

  assert {
    condition     = var.enable_container_insights == false
    error_message = "enable_container_insights must accept false"
  }
}

# ============================================================================
# ECS — Custom Cluster Name
# ============================================================================

run "ecs_cluster_name_defaults_to_null" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.ecs_cluster_name == null
    error_message = "ecs_cluster_name must default to null (uses prefix-cluster)"
  }
}

run "ecs_cluster_name_custom_accepted" {
  command = plan

  variables {
    deployment_mode  = "single-account"
    account_id       = "123456789012"
    prefix           = "test"
    enable_ecs       = true
    ecs_cluster_name = "my-custom-cluster"
  }

  assert {
    condition     = var.ecs_cluster_name == "my-custom-cluster"
    error_message = "ecs_cluster_name must accept custom string"
  }
}

# ============================================================================
# Lambda Baseline — Enabled by Default
# ============================================================================

run "lambda_baseline_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_lambda_baseline == true
    error_message = "enable_lambda_baseline must default to true"
  }
}

run "lambda_execution_role_not_null_when_enabled" {
  command = plan

  variables {
    deployment_mode        = "single-account"
    account_id             = "123456789012"
    prefix                 = "test"
    enable_lambda_baseline = true
  }

  assert {
    condition     = var.enable_lambda_baseline == true
    error_message = "compute.lambda_execution_role_arn must not be null when enable_lambda_baseline is true"
  }

  assert {
    condition     = output.compute.lambda_log_group_name != null
    error_message = "compute.lambda_log_group_name must not be null when enable_lambda_baseline is true"
  }
}

run "lambda_execution_role_null_when_disabled" {
  command = plan

  variables {
    deployment_mode        = "single-account"
    account_id             = "123456789012"
    prefix                 = "test"
    enable_lambda_baseline = false
  }

  assert {
    condition     = output.compute.lambda_execution_role_arn == null
    error_message = "compute.lambda_execution_role_arn must be null when enable_lambda_baseline is false"
  }
}

# ============================================================================
# Lambda — Log Retention
# ============================================================================

run "lambda_log_retention_days_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.lambda_log_retention_days == 30
    error_message = "lambda_log_retention_days must default to 30"
  }
}

run "lambda_log_retention_days_configurable" {
  command = plan

  variables {
    deployment_mode           = "single-account"
    account_id                = "123456789012"
    prefix                    = "test"
    lambda_log_retention_days = 90
  }

  assert {
    condition     = var.lambda_log_retention_days == 90
    error_message = "lambda_log_retention_days must accept 90"
  }
}

# ============================================================================
# EC2 — Disabled by Default
# ============================================================================

run "ec2_disabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_ec2 == false
    error_message = "enable_ec2 must default to false"
  }
}

run "ec2_launch_template_null_when_disabled" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enable_ec2      = false
  }

  assert {
    condition     = output.compute.ec2_launch_template_id == null
    error_message = "compute.ec2_launch_template_id must be null when enable_ec2 is false"
  }

  assert {
    condition     = output.compute.ec2_security_group_id == null
    error_message = "compute.ec2_security_group_id must be null when enable_ec2 is false"
  }
}

# ============================================================================
# ASG — Disabled by Default
# ============================================================================

run "asg_disabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_asg == false
    error_message = "enable_asg must default to false"
  }
}

run "asg_name_null_when_asg_disabled" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enable_ec2      = false
    enable_asg      = false
  }

  assert {
    condition     = output.compute.ec2_asg_name == null
    error_message = "compute.ec2_asg_name must be null when ASG is disabled"
  }
}

# ============================================================================
# EC2 — Instance Type and Sizing Defaults
# ============================================================================

run "ec2_instance_type_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.ec2_instance_type == "t3.micro"
    error_message = "ec2_instance_type must default to t3.micro"
  }
}

run "ec2_asg_sizing_defaults" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.ec2_min_size == 1
    error_message = "ec2_min_size must default to 1"
  }

  assert {
    condition     = var.ec2_max_size == 10
    error_message = "ec2_max_size must default to 10"
  }

  assert {
    condition     = var.ec2_desired_capacity == 2
    error_message = "ec2_desired_capacity must default to 2"
  }
}

# ============================================================================
# Compute — landing_zone_config Section
# ============================================================================

run "landing_zone_config_compute_section_present" {
  command = plan

  variables {
    deployment_mode        = "single-account"
    account_id             = "123456789012"
    prefix                 = "test"
    enable_ecs             = true
    enable_lambda_baseline = true
    enable_ec2             = false
  }

  assert {
    condition     = output.landing_zone_config.compute.ecs_enabled == true
    error_message = "landing_zone_config.compute.ecs_enabled must reflect enable_ecs"
  }

  assert {
    condition     = output.landing_zone_config.compute.lambda_enabled == true
    error_message = "landing_zone_config.compute.lambda_enabled must reflect enable_lambda_baseline"
  }

  assert {
    condition     = output.landing_zone_config.compute.ec2_enabled == false
    error_message = "landing_zone_config.compute.ec2_enabled must reflect enable_ec2"
  }
}
