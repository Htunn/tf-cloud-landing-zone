variable "enable_kms_key" {
  description = "Create a KMS Customer Managed Key for encryption"
  type        = bool
  default     = true
}

variable "kms_key_deletion_window_in_days" {
  description = "KMS key deletion waiting period in days (7-30)"
  type        = number
  default     = 30

  validation {
    condition     = var.kms_key_deletion_window_in_days >= 7 && var.kms_key_deletion_window_in_days <= 30
    error_message = "kms_key_deletion_window_in_days must be between 7 and 30."
  }
}

variable "kms_key_alias" {
  description = "Alias for the KMS key (without the 'alias/' prefix)"
  type        = string
}

variable "enable_multi_region" {
  description = "Enable multi-region KMS key for cross-region replication"
  type        = bool
  default     = false
}

variable "key_administrators" {
  description = "List of IAM principal ARNs granted key administration permissions"
  type        = list(string)
  default     = []
}

variable "key_users" {
  description = "List of IAM principal ARNs granted cryptographic usage permissions"
  type        = list(string)
  default     = []
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
