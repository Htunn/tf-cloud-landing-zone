variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "account_alias" {
  description = "IAM account alias (optional)"
  type        = string
  default     = null
}
