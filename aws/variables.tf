# ============================================================================
# Deployment Mode Configuration
# ============================================================================

variable "deployment_mode" {
  description = "Deployment mode: 'single-account' for standalone account deployment, 'organization' for AWS Organization multi-account deployment"
  type        = string
  default     = "single-account"

  validation {
    condition     = contains(["single-account", "organization"], var.deployment_mode)
    error_message = "deployment_mode must be either 'single-account' or 'organization'."
  }
}

# ============================================================================
# Organization Mode Variables
# ============================================================================

variable "organization_id" {
  description = "AWS Organization ID. Required when deployment_mode is 'organization'. Example: 'o-1234567890'"
  type        = string
  default     = null

  validation {
    condition     = var.organization_id == null || can(regex("^o-[a-z0-9]{10,32}$", var.organization_id))
    error_message = "organization_id must be a valid AWS Organization ID (format: o-xxxxxxxxxx)."
  }
}

variable "organization_root_id" {
  description = "Root Organizational Unit ID. Required when creating OUs in organization mode. Example: 'r-abc123'"
  type        = string
  default     = null
}

variable "organizational_units" {
  description = "Map of organizational units to create. Only used in organization mode."
  type = map(object({
    name      = string
    parent_id = string
  }))
  default = {}
}

variable "service_control_policies" {
  description = "Map of Service Control Policies to create and attach. Only used in organization mode."
  type = map(object({
    name        = string
    description = string
    content     = string
    targets     = list(string) # List of OU IDs or account IDs to attach the policy to
  }))
  default = {}
}

variable "organization_master_account_id" {
  description = "AWS Organization master account ID. Used for output in organization mode."
  type        = string
  default     = null
}

# ============================================================================
# Single Account Mode Variables
# ============================================================================

variable "account_id" {
  description = "AWS Account ID. Required when deployment_mode is 'single-account'. Must be a 12-digit number."
  type        = string
  default     = null

  validation {
    condition     = var.account_id == null || can(regex("^[0-9]{12}$", var.account_id))
    error_message = "account_id must be a valid 12-digit AWS Account ID."
  }
}

variable "account_alias" {
  description = "IAM account alias. Optional for single-account mode."
  type        = string
  default     = null
}

# ============================================================================
# Common Configuration
# ============================================================================

variable "prefix" {
  description = "Prefix to use for all resource names. Helps with resource organization and identification."
  type        = string
  default     = "landing-zone"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.prefix))
    error_message = "prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "enabled_regions" {
  description = "List of AWS regions to enable security services and deploy regional resources."
  type        = list(string)
  default     = ["us-east-1"]

  validation {
    condition     = length(var.enabled_regions) > 0
    error_message = "At least one AWS region must be specified."
  }
}

variable "tags" {
  description = "Common tags to apply to all resources created by this module."
  type        = map(string)
  default = {
    ManagedBy   = "terraform"
    Module      = "aws-landing-zone"
    Environment = "production"
  }
}

# ============================================================================
# Networking Configuration
# ============================================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC. Must be a valid IPv4 CIDR block."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones for subnet deployment. If empty, uses first 3 AZs in the primary region."
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet internet access. Incurs additional costs."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all AZs (cost optimization) vs one per AZ (high availability)."
  type        = bool
  default     = false
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs for network traffic analysis."
  type        = bool
  default     = true
}

variable "enable_transit_gateway" {
  description = "Enable Transit Gateway for multi-VPC connectivity. Only relevant in organization mode."
  type        = bool
  default     = false
}

# ============================================================================
# Security Services Configuration
# ============================================================================

variable "enable_guardduty" {
  description = "Enable Amazon GuardDuty for threat detection."
  type        = bool
  default     = true
}

variable "enable_guardduty_delegated_admin" {
  description = "Enable GuardDuty delegated administrator. Only used in organization mode."
  type        = bool
  default     = false
}

variable "guardduty_delegated_admin_account_id" {
  description = "Account ID for GuardDuty delegated administrator. Required if enable_guardduty_delegated_admin is true."
  type        = string
  default     = null
}

variable "guardduty_finding_publishing_frequency" {
  description = "Frequency of GuardDuty findings publication. Valid values: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS."
  type        = string
  default     = "SIX_HOURS"

  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.guardduty_finding_publishing_frequency)
    error_message = "guardduty_finding_publishing_frequency must be FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  }
}

variable "enable_security_hub" {
  description = "Enable AWS Security Hub for centralized security findings."
  type        = bool
  default     = true
}

variable "enable_security_hub_cis_standard" {
  description = "Enable CIS AWS Foundations Benchmark standard in Security Hub."
  type        = bool
  default     = true
}

variable "enable_security_hub_aws_foundational_standard" {
  description = "Enable AWS Foundational Security Best Practices standard in Security Hub."
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Enable AWS Config for resource compliance monitoring. Can be expensive in large environments."
  type        = bool
  default     = true
}

variable "enable_macie" {
  description = "Enable Amazon Macie for sensitive data discovery."
  type        = bool
  default     = false
}

# ============================================================================
# Logging and Monitoring Configuration
# ============================================================================

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail for API activity logging."
  type        = bool
  default     = true
}

variable "cloudtrail_enable_log_file_validation" {
  description = "Enable CloudTrail log file validation for integrity verification."
  type        = bool
  default     = true
}

variable "cloudwatch_log_retention_days" {
  description = "CloudWatch Logs retention period in days. Valid values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653"
  type        = number
  default     = 90

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.cloudwatch_log_retention_days)
    error_message = "cloudwatch_log_retention_days must be a valid retention period."
  }
}

variable "enable_centralized_logging_bucket" {
  description = "Create a centralized S3 bucket for log aggregation."
  type        = bool
  default     = true
}

# ============================================================================
# IAM Configuration
# ============================================================================

variable "enable_iam_access_analyzer" {
  description = "Enable IAM Access Analyzer for identifying resources shared with external entities."
  type        = bool
  default     = true
}

variable "iam_password_policy" {
  description = "IAM password policy configuration."
  type = object({
    minimum_password_length        = number
    require_lowercase_characters   = bool
    require_uppercase_characters   = bool
    require_numbers                = bool
    require_symbols                = bool
    allow_users_to_change_password = bool
    max_password_age               = number
    password_reuse_prevention      = number
  })
  default = {
    minimum_password_length        = 14
    require_lowercase_characters   = true
    require_uppercase_characters   = true
    require_numbers                = true
    require_symbols                = true
    allow_users_to_change_password = true
    max_password_age               = 90
    password_reuse_prevention      = 24
  }
}

variable "enable_cross_account_roles" {
  description = "Create cross-account IAM roles. Only relevant in organization mode."
  type        = bool
  default     = false
}

# ============================================================================
# KMS Configuration
# ============================================================================

variable "enable_kms_key" {
  description = "Create a KMS key for encryption of resources."
  type        = bool
  default     = true
}

variable "kms_key_deletion_window_in_days" {
  description = "KMS key deletion waiting period in days (7-30)."
  type        = number
  default     = 30

  validation {
    condition     = var.kms_key_deletion_window_in_days >= 7 && var.kms_key_deletion_window_in_days <= 30
    error_message = "kms_key_deletion_window_in_days must be between 7 and 30."
  }
}

variable "enable_kms_multi_region" {
  description = "Enable multi-region replication for the KMS key."
  type        = bool
  default     = false
}

variable "kms_key_administrators" {
  description = "List of IAM principal ARNs granted KMS key administration permissions."
  type        = list(string)
  default     = []
}

variable "kms_key_users" {
  description = "List of IAM principal ARNs granted KMS cryptographic usage permissions."
  type        = list(string)
  default     = []
}

# ============================================================================
# ECR Configuration
# ============================================================================

variable "ecr_repositories" {
  description = "Map of ECR repositories to create. Key is used as a name suffix: <prefix>-<key>."
  type = map(object({
    image_tag_mutability = optional(string, "MUTABLE")
    scan_on_push         = optional(bool, true)
    force_delete         = optional(bool, false)
  }))
  default = {}
}

variable "ecr_lifecycle_policy_keep_count" {
  description = "Maximum number of tagged images to retain per ECR repository."
  type        = number
  default     = 20
}

variable "ecr_untagged_image_expiry_days" {
  description = "Number of days before untagged ECR images are expired."
  type        = number
  default     = 7
}

variable "ecr_enable_cross_account_pull" {
  description = "Attach a repository policy allowing cross-account image pulls."
  type        = bool
  default     = false
}

variable "ecr_cross_account_ids" {
  description = "AWS account IDs allowed to pull ECR images (requires ecr_enable_cross_account_pull = true)."
  type        = list(string)
  default     = []
}

# ============================================================================
# Compute Configuration
# ============================================================================

variable "enable_ecs" {
  description = "Enable ECS cluster with Fargate and Fargate Spot capacity providers."
  type        = bool
  default     = true
}

variable "ecs_cluster_name" {
  description = "Name for the ECS cluster. Defaults to <prefix>-cluster when null."
  type        = string
  default     = null
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for the ECS cluster."
  type        = bool
  default     = true
}

variable "enable_lambda_baseline" {
  description = "Create a shared Lambda IAM execution role and CloudWatch log group."
  type        = bool
  default     = true
}

variable "lambda_log_retention_days" {
  description = "CloudWatch Logs retention period for Lambda logs in days."
  type        = number
  default     = 30
}

variable "enable_ec2" {
  description = "Enable EC2 launch template for EC2-based workloads."
  type        = bool
  default     = false
}

variable "enable_asg" {
  description = "Enable Auto Scaling Group for EC2 instances. Requires enable_ec2 = true."
  type        = bool
  default     = false
}

variable "ec2_instance_type" {
  description = "EC2 instance type for the launch template."
  type        = string
  default     = "t3.micro"
}

variable "ec2_ami_id" {
  description = "AMI ID for the EC2 launch template. Required when enable_ec2 = true."
  type        = string
  default     = null
}

variable "ec2_min_size" {
  description = "Minimum number of EC2 instances in the Auto Scaling Group."
  type        = number
  default     = 1
}

variable "ec2_max_size" {
  description = "Maximum number of EC2 instances in the Auto Scaling Group."
  type        = number
  default     = 10
}

variable "ec2_desired_capacity" {
  description = "Desired number of EC2 instances in the Auto Scaling Group."
  type        = number
  default     = 2
}

# ============================================================================
# Database Configuration
# ============================================================================

variable "enable_rds" {
  description = "Enable RDS Aurora Serverless v2 cluster."
  type        = bool
  default     = false
}

variable "enable_dynamodb" {
  description = "Enable DynamoDB table."
  type        = bool
  default     = false
}

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
  description = "Aurora engine version."
  type        = string
  default     = "16.4"
}

variable "db_cluster_identifier" {
  description = "RDS cluster identifier. Defaults to <prefix>-db-cluster when null."
  type        = string
  default     = null
}

variable "db_name" {
  description = "Name of the initial database to create."
  type        = string
  default     = "appdb"
}

variable "db_master_username" {
  description = "Master username for the RDS cluster."
  type        = string
  default     = "dbadmin"
}

variable "db_master_password" {
  description = "Master password for the RDS cluster. Required when enable_rds = true."
  type        = string
  sensitive   = true
  default     = null
}

variable "db_instance_class" {
  description = "Instance class for RDS cluster instances."
  type        = string
  default     = "db.serverless"
}

variable "db_instance_count" {
  description = "Number of RDS cluster instances (writer + readers)."
  type        = number
  default     = 1
}

variable "db_min_capacity" {
  description = "Minimum Aurora Serverless v2 capacity in ACUs (0.5–128)."
  type        = number
  default     = 0.5
}

variable "db_max_capacity" {
  description = "Maximum Aurora Serverless v2 capacity in ACUs (0.5–128)."
  type        = number
  default     = 16
}

variable "db_enable_deletion_protection" {
  description = "Enable RDS cluster deletion protection."
  type        = bool
  default     = true
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot when the RDS cluster is deleted."
  type        = bool
  default     = false
}

variable "db_backup_retention_period" {
  description = "Number of days to retain automated RDS backups."
  type        = number
  default     = 7
}

variable "db_preferred_backup_window" {
  description = "Daily time range for automated RDS backups (UTC, e.g. '03:00-04:00')."
  type        = string
  default     = "03:00-04:00"
}

variable "db_enable_performance_insights" {
  description = "Enable Performance Insights for RDS cluster instances."
  type        = bool
  default     = true
}

variable "db_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the RDS cluster."
  type        = list(string)
  default     = []
}

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
  description = "Attribute name for the DynamoDB table hash key."
  type        = string
  default     = "id"
}

variable "dynamodb_hash_key_type" {
  description = "Hash key attribute type: S (string), N (number), or B (binary)."
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
  description = "Range key attribute type: S (string), N (number), or B (binary)."
  type        = string
  default     = "S"

  validation {
    condition     = contains(["S", "N", "B"], var.dynamodb_range_key_type)
    error_message = "dynamodb_range_key_type must be S, N, or B."
  }
}

variable "dynamodb_enable_point_in_time_recovery" {
  description = "Enable DynamoDB point-in-time recovery."
  type        = bool
  default     = true
}
