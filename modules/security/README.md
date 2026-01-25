# Security Module

Comprehensive security baseline for AWS accounts including:

- **GuardDuty**: Threat detection service
- **Security Hub**: Centralized security findings
- **AWS Config**: Resource compliance monitoring
- **Macie**: Sensitive data discovery

## Features

- Multi-region support
- Organization-wide delegated administration
- Industry standard compliance (CIS, AWS Foundational)
- Automated threat detection and monitoring

## Usage

```hcl
module "security" {
  source = "./modules/security"

  deployment_mode = "single-account"
  enabled_regions = ["us-east-1", "us-west-2"]
  primary_region  = "us-east-1"
  
  enable_guardduty    = true
  enable_security_hub = true
  enable_config       = true
  enable_macie        = false
  
  kms_key_id = aws_kms_key.main.arn
  
  prefix = "my-company"
  tags   = {
    Environment = "production"
  }
}
```
