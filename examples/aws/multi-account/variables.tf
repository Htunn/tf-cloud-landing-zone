variable "organization_id" {
  description = "AWS Organization ID"
  type        = string

  validation {
    condition     = can(regex("^o-[a-z0-9]{10,32}$", var.organization_id))
    error_message = "Organization ID must be in format o-xxxxxxxxxx."
  }
}

variable "organization_root_id" {
  description = "AWS Organization root ID"
  type        = string

  validation {
    condition     = can(regex("^r-[a-z0-9]{4,32}$", var.organization_root_id))
    error_message = "Organization root ID must be in format r-xxxx."
  }
}

variable "organization_master_account_id" {
  description = "AWS Organization management/master account ID"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.organization_master_account_id))
    error_message = "Account ID must be a 12-digit number."
  }
}

variable "security_account_id" {
  description = "Security tooling account ID (delegated administrator)"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.security_account_id))
    error_message = "Account ID must be a 12-digit number."
  }
}

variable "log_archive_account_id" {
  description = "Log archive account ID"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.log_archive_account_id))
    error_message = "Account ID must be a 12-digit number."
  }
}

variable "prefix" {
  description = "Prefix for resource naming"
  type        = string
  default     = "org"

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
  default     = ["us-east-1", "us-west-2"]
}

variable "vpc_cidr" {
  description = "CIDR block for shared services VPC"
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

variable "admin_trusted_accounts" {
  description = "List of AWS account IDs that can assume admin role"
  type        = list(string)
  default     = []
}

variable "cost_center" {
  description = "Cost center for billing attribution"
  type        = string
  default     = "Infrastructure"
}

variable "business_unit" {
  description = "Business unit responsible for the organization"
  type        = string
  default     = "Corporate IT"
}
