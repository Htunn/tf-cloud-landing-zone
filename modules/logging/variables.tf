variable "deployment_mode" {
  description = "Deployment mode: single-account or organization"
  type        = string
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "organization_id" {
  description = "AWS Organization ID (for organization mode)"
  type        = string
  default     = null
}

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail"
  type        = bool
  default     = true
}

variable "cloudtrail_enable_log_file_validation" {
  description = "Enable CloudTrail log file validation"
  type        = bool
  default     = true
}

variable "is_organization_trail" {
  description = "Whether this is an organization trail"
  type        = bool
  default     = false
}

variable "enable_centralized_logging_bucket" {
  description = "Create centralized S3 bucket for log aggregation"
  type        = bool
  default     = true
}

variable "cloudwatch_log_retention_days" {
  description = "CloudWatch Logs retention period in days"
  type        = number
  default     = 90
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
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
