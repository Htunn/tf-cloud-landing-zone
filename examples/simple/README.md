# Example: Simple Single-Account Deployment

This example demonstrates a minimal single-account deployment with basic security services.

## Features

- Single VPC with public/private subnets
- GuardDuty and Security Hub enabled
- CloudTrail for audit logging
- Basic IAM configuration

## Prerequisites

- AWS account
- Terraform >= 1.6.0
- AWS CLI configured with appropriate credentials

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars`:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your values:
```bash
vi terraform.tfvars
```

3. Initialize Terraform:
```bash
terraform init
```

4. Review the plan:
```bash
terraform plan
```

5. Apply the configuration:
```bash
terraform apply
```

## Inputs

| Name | Description | Required |
|------|-------------|----------|
| account_id | Your AWS Account ID | Yes |
| aws_region | AWS region to deploy to | No |

## Outputs

- `vpc_id` - VPC ID
- `security_services` - Security services configuration
- `logging_config` - Logging configuration

## Clean Up

```bash
terraform destroy
```

## Estimated Monthly Cost

- VPC: ~$0 (free tier)
- NAT Gateway: ~$32/month
- GuardDuty: ~$4/month (after free trial)
- Security Hub: ~$0.001/check
- CloudTrail: ~$2/month
- S3 Storage: ~$1/month

**Total: ~$40-50/month**
