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
