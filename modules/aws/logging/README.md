# Logging Module

Centralized logging and audit trail configuration:

- **CloudTrail**: API activity logging
- **CloudWatch Logs**: Centralized log aggregation
- **S3 Buckets**: Long-term log storage with lifecycle policies

## Features

- Organization-wide trail support
- Multi-region logging
- Log file validation
- CloudWatch Logs integration
- S3 lifecycle policies for cost optimization
- Encryption at rest

## Usage

```hcl
module "logging" {
  source = "./modules/logging"

  deployment_mode         = "single-account"
  primary_region          = "us-east-1"
  account_id              = "123456789012"
  
  enable_cloudtrail       = true
  is_organization_trail   = false
  
  cloudwatch_log_retention_days = 90
  
  kms_key_id = aws_kms_key.main.arn
  
  prefix = "my-company"
  tags   = {
    Environment = "production"
  }
}
```
