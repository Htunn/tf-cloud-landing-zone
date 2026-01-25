terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # Uncomment for remote state
  # backend "s3" {
  #   bucket         = "my-terraform-state-bucket"
  #   key            = "landing-zone/simple/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "landing-zone-simple"
      ManagedBy   = "terraform"
      Environment = "development"
    }
  }
}
