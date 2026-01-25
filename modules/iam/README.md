# IAM Module

This module configures IAM security best practices including:

- IAM account alias
- Strong password policy
- IAM Access Analyzer
- Cross-account assume roles (organization mode)
- Permission boundary policies

## Features

- **Password Policy**: Enforces strong password requirements
- **Access Analyzer**: Detects unintended resource sharing
- **Cross-Account Roles**: Standardized roles for org-wide access
- **Permission Boundaries**: Limits maximum permissions

## Usage

```hcl
module "iam" {
  source = "./modules/iam"

  deployment_mode            = "single-account"
  account_alias              = "my-company-prod"
  enable_iam_access_analyzer = true
  
  iam_password_policy = {
    minimum_password_length        = 14
    require_lowercase_characters   = true
    require_uppercase_characters   = true
    require_numbers                = true
    require_symbols                = true
    allow_users_to_change_password = true
    max_password_age               = 90
    password_reuse_prevention      = 24
  }
  
  prefix = "my-company"
  tags   = {
    Environment = "production"
  }
}
```
