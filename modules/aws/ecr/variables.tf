variable "repositories" {
  description = "Map of ECR repositories to create. Key is used as a name suffix: <prefix>-<key>."
  type = map(object({
    image_tag_mutability = optional(string, "MUTABLE")
    scan_on_push         = optional(bool, true)
    force_delete         = optional(bool, false)
  }))
  default = {}
}

variable "lifecycle_policy_keep_count" {
  description = "Maximum number of tagged images to retain per repository"
  type        = number
  default     = 20
}

variable "untagged_image_expiry_days" {
  description = "Number of days after which untagged images are expired"
  type        = number
  default     = 7
}

variable "kms_key_arn" {
  description = "KMS key ARN for repository encryption. Uses AES256 if null."
  type        = string
  default     = null
}

variable "enable_cross_account_pull" {
  description = "Attach a repository policy allowing image pulls from other AWS accounts"
  type        = bool
  default     = false
}

variable "cross_account_ids" {
  description = "List of AWS account IDs allowed to pull images (requires enable_cross_account_pull = true)"
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
