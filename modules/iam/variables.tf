variable "deployment_mode" {
  description = "Deployment mode: single-account or organization"
  type        = string
}

variable "account_alias" {
  description = "IAM account alias"
  type        = string
  default     = null
}

variable "enable_iam_access_analyzer" {
  description = "Enable IAM Access Analyzer"
  type        = bool
  default     = true
}

variable "iam_password_policy" {
  description = "IAM password policy configuration"
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
}

variable "enable_cross_account_roles" {
  description = "Create cross-account IAM roles (organization mode only)"
  type        = bool
  default     = false
}

variable "organization_id" {
  description = "AWS Organization ID (for organization mode)"
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
