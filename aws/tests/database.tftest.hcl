# ============================================================================
# Database Module Tests
# ============================================================================
# Covers: RDS disabled by default, DynamoDB disabled by default, engine
# validation, db_engine_version default, instance class default, deletion
# protection default, backup retention, serverless capacity bounds, DynamoDB
# billing mode validation, hash/range key type validation, point-in-time
# recovery default, database output block structure, and landing_zone_config.
# ============================================================================

# ============================================================================
# RDS — Disabled by Default
# ============================================================================

run "rds_disabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_rds == false
    error_message = "enable_rds must default to false"
  }
}

run "rds_outputs_null_when_disabled" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enable_rds      = false
  }

  assert {
    condition     = output.database.rds_cluster_endpoint == null
    error_message = "database.rds_cluster_endpoint must be null when enable_rds is false"
  }

  assert {
    condition     = output.database.rds_cluster_reader_endpoint == null
    error_message = "database.rds_cluster_reader_endpoint must be null when enable_rds is false"
  }

  assert {
    condition     = output.database.rds_cluster_id == null
    error_message = "database.rds_cluster_id must be null when enable_rds is false"
  }

  assert {
    condition     = output.database.rds_security_group_id == null
    error_message = "database.rds_security_group_id must be null when enable_rds is false"
  }
}

# ============================================================================
# RDS — Engine Validation
# ============================================================================

run "rds_engine_default_aurora_postgresql" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.db_engine == "aurora-postgresql"
    error_message = "db_engine must default to aurora-postgresql"
  }
}

run "rds_engine_aurora_mysql_accepted" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    db_engine       = "aurora-mysql"
  }

  assert {
    condition     = var.db_engine == "aurora-mysql"
    error_message = "db_engine must accept aurora-mysql"
  }
}

run "rds_engine_invalid_value_rejected" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    db_engine       = "mysql"
  }

  expect_failures = [
    var.db_engine
  ]
}

# ============================================================================
# RDS — Instance Class Default
# ============================================================================

run "rds_instance_class_default_serverless" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.db_instance_class == "db.serverless"
    error_message = "db_instance_class must default to db.serverless"
  }
}

# ============================================================================
# RDS — Deletion Protection Default
# ============================================================================

run "rds_deletion_protection_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.db_enable_deletion_protection == true
    error_message = "db_enable_deletion_protection must default to true"
  }
}

run "rds_skip_final_snapshot_disabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.db_skip_final_snapshot == false
    error_message = "db_skip_final_snapshot must default to false"
  }
}

# ============================================================================
# RDS — Backup Retention and Serverless Capacity
# ============================================================================

run "rds_backup_retention_default_7_days" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.db_backup_retention_period == 7
    error_message = "db_backup_retention_period must default to 7"
  }
}

run "rds_serverless_capacity_defaults" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.db_min_capacity == 0.5
    error_message = "db_min_capacity must default to 0.5 ACUs"
  }

  assert {
    condition     = var.db_max_capacity == 16
    error_message = "db_max_capacity must default to 16 ACUs"
  }
}

run "rds_instance_count_default_1" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.db_instance_count == 1
    error_message = "db_instance_count must default to 1"
  }
}

# ============================================================================
# DynamoDB — Disabled by Default
# ============================================================================

run "dynamodb_disabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.enable_dynamodb == false
    error_message = "enable_dynamodb must default to false"
  }
}

run "dynamodb_outputs_null_when_disabled" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
    enable_dynamodb = false
  }

  assert {
    condition     = output.database.dynamodb_table_name == null
    error_message = "database.dynamodb_table_name must be null when enable_dynamodb is false"
  }

  assert {
    condition     = output.database.dynamodb_table_arn == null
    error_message = "database.dynamodb_table_arn must be null when enable_dynamodb is false"
  }
}

# ============================================================================
# DynamoDB — Billing Mode Validation
# ============================================================================

run "dynamodb_billing_mode_default_pay_per_request" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.dynamodb_billing_mode == "PAY_PER_REQUEST"
    error_message = "dynamodb_billing_mode must default to PAY_PER_REQUEST"
  }
}

run "dynamodb_billing_mode_provisioned_accepted" {
  command = plan

  variables {
    deployment_mode       = "single-account"
    account_id            = "123456789012"
    prefix                = "test"
    dynamodb_billing_mode = "PROVISIONED"
  }

  assert {
    condition     = var.dynamodb_billing_mode == "PROVISIONED"
    error_message = "dynamodb_billing_mode must accept PROVISIONED"
  }
}

run "dynamodb_billing_mode_invalid_rejected" {
  command = plan

  variables {
    deployment_mode       = "single-account"
    account_id            = "123456789012"
    prefix                = "test"
    dynamodb_billing_mode = "ON_DEMAND"
  }

  expect_failures = [
    var.dynamodb_billing_mode
  ]
}

# ============================================================================
# DynamoDB — Hash/Range Key Type Validation
# ============================================================================

run "dynamodb_hash_key_type_default_string" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.dynamodb_hash_key_type == "S"
    error_message = "dynamodb_hash_key_type must default to S (string)"
  }
}

run "dynamodb_hash_key_type_number_accepted" {
  command = plan

  variables {
    deployment_mode        = "single-account"
    account_id             = "123456789012"
    prefix                 = "test"
    dynamodb_hash_key_type = "N"
  }

  assert {
    condition     = var.dynamodb_hash_key_type == "N"
    error_message = "dynamodb_hash_key_type must accept N (number)"
  }
}

run "dynamodb_hash_key_type_invalid_rejected" {
  command = plan

  variables {
    deployment_mode        = "single-account"
    account_id             = "123456789012"
    prefix                 = "test"
    dynamodb_hash_key_type = "X"
  }

  expect_failures = [
    var.dynamodb_hash_key_type
  ]
}

run "dynamodb_range_key_type_invalid_rejected" {
  command = plan

  variables {
    deployment_mode         = "single-account"
    account_id              = "123456789012"
    prefix                  = "test"
    dynamodb_range_key_type = "Z"
  }

  expect_failures = [
    var.dynamodb_range_key_type
  ]
}

# ============================================================================
# DynamoDB — Point-in-Time Recovery Default
# ============================================================================

run "dynamodb_pitr_enabled_by_default" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = var.dynamodb_enable_point_in_time_recovery == true
    error_message = "dynamodb_enable_point_in_time_recovery must default to true"
  }
}

# ============================================================================
# Database — landing_zone_config Section
# ============================================================================

run "landing_zone_config_database_section_defaults" {
  command = plan

  variables {
    deployment_mode = "single-account"
    account_id      = "123456789012"
    prefix          = "test"
  }

  assert {
    condition     = output.landing_zone_config.database.rds_enabled == false
    error_message = "landing_zone_config.database.rds_enabled must reflect enable_rds default"
  }

  assert {
    condition     = output.landing_zone_config.database.dynamodb_enabled == false
    error_message = "landing_zone_config.database.dynamodb_enabled must reflect enable_dynamodb default"
  }
}
