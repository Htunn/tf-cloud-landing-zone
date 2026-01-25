terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration for organization-wide state
  # backend "s3" {
  #   bucket         = "your-org-terraform-state"
  #   key            = "landing-zone/organization/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  #   role_arn       = "arn:aws:iam::MANAGEMENT-ACCOUNT-ID:role/TerraformStateRole"
  # }
}

provider "aws" {
  region = var.primary_region

  # Use management account credentials
  # For member account resources, use assume_role
  
  default_tags {
    tags = {
      ManagedBy    = "Terraform"
      Organization = var.prefix
      LandingZone  = "v1"
    }
  }
}

# Additional provider for Security Tooling account (delegated admin)
provider "aws" {
  alias  = "security"
  region = var.primary_region
  
  assume_role {
    role_arn = "arn:aws:iam::${var.security_account_id}:role/OrganizationAccountAccessRole"
  }

  default_tags {
    tags = {
      ManagedBy    = "Terraform"
      Organization = var.prefix
      Account      = "Security"
    }
  }
}

# Provider for Log Archive account
provider "aws" {
  alias  = "logging"
  region = var.primary_region
  
  assume_role {
    role_arn = "arn:aws:iam::${var.log_archive_account_id}:role/OrganizationAccountAccessRole"
  }

  default_tags {
    tags = {
      ManagedBy    = "Terraform"
      Organization = var.prefix
      Account      = "LogArchive"
    }
  }
}
