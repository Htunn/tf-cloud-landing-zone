variable "account_id" {
  description = "AWS Account ID"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "Account ID must be a 12-digit number."
  }
}

variable "prefix" {
  description = "Prefix for resource naming"
  type        = string
  default     = "complete"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.prefix))
    error_message = "Prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "enabled_regions" {
  description = "List of AWS regions to enable services in"
  type        = list(string)
  default     = ["us-east-1"]
}

variable "environment" {
  description = "Environment name (e.g., production, staging, development)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "Environment must be production, staging, or development."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "security_audit_role_trusted_accounts" {
  description = "List of AWS account IDs that can assume the security audit role"
  type        = list(string)
  default     = []
}

variable "admin_role_trusted_accounts" {
  description = "List of AWS account IDs that can assume the admin role"
  type        = list(string)
  default     = []
}

variable "read_only_role_trusted_accounts" {
  description = "List of AWS account IDs that can assume the read-only role"
  type        = list(string)
  default     = []
}

variable "cost_center" {
  description = "Cost center for billing attribution"
  type        = string
  default     = "Engineering"
}

variable "owner" {
  description = "Team or individual responsible for the resources"
  type        = string
  default     = "Platform Team"
}
