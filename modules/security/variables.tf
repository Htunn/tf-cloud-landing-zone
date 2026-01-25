variable "deployment_mode" {
  description = "Deployment mode: single-account or organization"
  type        = string
}

variable "enabled_regions" {
  description = "List of AWS regions to enable security services"
  type        = list(string)
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
}

variable "enable_guardduty" {
  description = "Enable Amazon GuardDuty"
  type        = bool
  default     = true
}

variable "enable_guardduty_delegated_admin" {
  description = "Enable GuardDuty delegated administrator"
  type        = bool
  default     = false
}

variable "guardduty_delegated_admin_account_id" {
  description = "Account ID for GuardDuty delegated administrator"
  type        = string
  default     = null
}

variable "guardduty_finding_publishing_frequency" {
  description = "Frequency of GuardDuty findings publication"
  type        = string
  default     = "SIX_HOURS"
}

variable "enable_security_hub" {
  description = "Enable AWS Security Hub"
  type        = bool
  default     = true
}

variable "enable_security_hub_cis_standard" {
  description = "Enable CIS AWS Foundations Benchmark standard"
  type        = bool
  default     = true
}

variable "enable_security_hub_aws_foundational_standard" {
  description = "Enable AWS Foundational Security Best Practices standard"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Enable AWS Config"
  type        = bool
  default     = true
}

variable "enable_macie" {
  description = "Enable Amazon Macie"
  type        = bool
  default     = false
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
