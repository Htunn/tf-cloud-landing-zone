variable "enable_rds" {
  description = "Enable RDS Aurora Serverless v2 cluster"
  type        = bool
  default     = false
}

variable "enable_dynamodb" {
  description = "Enable DynamoDB table"
  type        = bool
  default     = false
}

# ============================================================================
# RDS Configuration
# ============================================================================

variable "db_engine" {
  description = "Aurora database engine. Valid values: aurora-mysql, aurora-postgresql."
  type        = string
  default     = "aurora-postgresql"

  validation {
    condition     = contains(["aurora-mysql", "aurora-postgresql"], var.db_engine)
    error_message = "db_engine must be aurora-mysql or aurora-postgresql."
  }
}

variable "db_engine_version" {
  description = "Aurora engine version"
  type        = string
  default     = "16.4"
}

variable "db_cluster_identifier" {
  description = "RDS cluster identifier. Defaults to <prefix>-db-cluster when null."
  type        = string
  default     = null
}

variable "db_name" {
  description = "Name of the initial database to create in the RDS cluster"
  type        = string
  default     = "appdb"
}

variable "db_master_username" {
  description = "Master username for the RDS cluster"
  type        = string
  default     = "dbadmin"
}

variable "db_master_password" {
  description = "Master password for the RDS cluster. Must be at least 8 characters."
  type        = string
  sensitive   = true
  default     = null
}

variable "db_instance_class" {
  description = "Instance class for RDS cluster instances"
  type        = string
  default     = "db.serverless"
}

variable "db_instance_count" {
  description = "Number of RDS cluster instances (writer + readers)"
  type        = number
  default     = 1
}

variable "db_min_capacity" {
  description = "Minimum Aurora Serverless v2 capacity in ACUs (0.5–128)"
  type        = number
  default     = 0.5
}

variable "db_max_capacity" {
  description = "Maximum Aurora Serverless v2 capacity in ACUs (0.5–128)"
  type        = number
  default     = 16
}

variable "enable_deletion_protection" {
  description = "Enable RDS cluster deletion protection"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when the RDS cluster is deleted"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated RDS backups (1–35)"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Daily time range for automated RDS backups (UTC, e.g. '03:00-04:00')"
  type        = string
  default     = "03:00-04:00"
}

variable "enable_performance_insights" {
  description = "Enable Performance Insights for RDS cluster instances"
  type        = bool
  default     = true
}

# ============================================================================
# DynamoDB Configuration
# ============================================================================

variable "dynamodb_table_name" {
  description = "DynamoDB table name. Defaults to <prefix>-table when null."
  type        = string
  default     = null
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode. Valid values: PAY_PER_REQUEST, PROVISIONED."
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.dynamodb_billing_mode)
    error_message = "dynamodb_billing_mode must be PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "dynamodb_hash_key" {
  description = "Attribute name for the DynamoDB table hash key"
  type        = string
  default     = "id"
}

variable "dynamodb_hash_key_type" {
  description = "Hash key attribute type: S (string), N (number), or B (binary)"
  type        = string
  default     = "S"

  validation {
    condition     = contains(["S", "N", "B"], var.dynamodb_hash_key_type)
    error_message = "dynamodb_hash_key_type must be S, N, or B."
  }
}

variable "dynamodb_range_key" {
  description = "Attribute name for the DynamoDB table range key. Optional."
  type        = string
  default     = null
}

variable "dynamodb_range_key_type" {
  description = "Range key attribute type: S (string), N (number), or B (binary)"
  type        = string
  default     = "S"

  validation {
    condition     = contains(["S", "N", "B"], var.dynamodb_range_key_type)
    error_message = "dynamodb_range_key_type must be S, N, or B."
  }
}

variable "enable_point_in_time_recovery" {
  description = "Enable DynamoDB point-in-time recovery"
  type        = bool
  default     = true
}

# ============================================================================
# Network and Encryption
# ============================================================================

variable "vpc_id" {
  description = "VPC ID for database subnet group and security group"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs to place the DB subnet group in"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the RDS cluster"
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "KMS key ARN for RDS storage and DynamoDB encryption. Uses AWS-managed key if null."
  type        = string
  default     = null
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default     = {}
}
