# AWS Cloud Landing Zone Terraform Module

[![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.6.0-blue.svg)](https://www.terraform.io/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![AWS Provider](https://img.shields.io/badge/AWS%20Provider-%3E%3D5.0-orange.svg)](https://registry.terraform.io/providers/hashicorp/aws/latest)

A production-ready Terraform module for deploying a secure AWS cloud landing zone with comprehensive security baseline, networking, IAM, logging, and monitoring capabilities.

## Features

✅ **Dual Deployment Modes**: Single-account or AWS Organizations multi-account  
✅ **Secure Networking**: VPC with multi-AZ subnets, NAT Gateway, VPC Flow Logs, Transit Gateway  
✅ **Security Baseline**: GuardDuty, Security Hub, AWS Config, Macie, IAM Access Analyzer  
✅ **Centralized Logging**: CloudTrail, CloudWatch Logs, S3 log aggregation  
✅ **IAM Best Practices**: Password policies, cross-account roles, permission boundaries  
✅ **Encryption**: KMS key management with automatic rotation  
✅ **Organization Support**: Service Control Policies, Organizational Units, delegated admin  
✅ **Production-Ready**: Comprehensive testing (Terraform + Terratest), CI/CD integration, cost-optimized defaults  
✅ **Complete Examples**: Simple, complete, and multi-account configurations  
✅ **SCP Library**: Pre-built Service Control Policies for common use cases

## Architecture

📊 **[View Interactive Diagrams](docs/architecture-diagrams.md)** - Comprehensive flowcharts, sequence diagrams, and component diagrams

This module supports two deployment architectures:

### Single-Account Mode
For standalone AWS accounts or when you don't have an AWS Organization.

```
┌─────────────────────────────────────────────┐
│           Single AWS Account                │
├─────────────────────────────────────────────┤
│  VPC (Multi-AZ)                             │
│  ├── Public Subnets                         │
│  ├── Private Subnets                        │
│  └── NAT Gateway / Internet Gateway         │
│                                             │
│  Security Services                          │
│  ├── GuardDuty                              │
│  ├── Security Hub                           │
│  ├── AWS Config                             │
│  └── IAM Access Analyzer                   │
│                                             │
│  Logging & Monitoring                       │
│  ├── CloudTrail                             │
│  ├── VPC Flow Logs                          │
│  └── CloudWatch Logs                        │
│                                             │
│  Encryption                                 │
│  └── KMS Key (with rotation)               │
└─────────────────────────────────────────────┘
```

### Organization Mode
For AWS Organizations with multiple member accounts.

```
┌─────────────────────────────────────────────┐
│      AWS Organizations (Management)         │
├─────────────────────────────────────────────┤
│  Organization Structure                     │
│  ├── Organizational Units                   │
│  ├── Service Control Policies               │
│  └── Member Accounts                        │
│                                             │
│  Delegated Administration                   │
│  ├── GuardDuty (Security Account)          │
│  └── Security Hub (Security Account)       │
│                                             │
│  Organization-Wide Services                 │
│  ├── Organization CloudTrail                │
│  ├── Transit Gateway                        │
│  └── Centralized Logging                    │
│                                             │
│  Per-Account Baseline (All Accounts)        │
│  ├── VPC & Networking                       │
│  ├── Security Services                      │
│  └── IAM Configuration                      │
└─────────────────────────────────────────────┘
```

## Quick Start

### Single-Account Deployment

```hcl
module "landing_zone" {
  source = "github.com/yourusername/tf-cloud-landing-zone"

  # Deployment mode
  deployment_mode = "single-account"
  account_id      = "123456789012"
  
  # Basic configuration
  prefix          = "my-company"
  enabled_regions = ["us-east-1", "us-west-2"]
  
  # Networking
  vpc_cidr           = "10.0.0.0/16"
  enable_nat_gateway = true
  
  # Security services
  enable_guardduty    = true
  enable_security_hub = true
  enable_config       = true
  
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Organization Deployment

```hcl
module "landing_zone" {
  source = "github.com/yourusername/tf-cloud-landing-zone"

  # Deployment mode
  deployment_mode          = "organization"
  organization_id          = "o-1234567890"
  organization_root_id     = "r-abc123"
  organization_master_account_id = "111111111111"
  
  # Organization structure
  organizational_units = {
    production = {
      name      = "Production"
      parent_id = "r-abc123"
    }
    development = {
      name      = "Development"
      parent_id = "r-abc123"
    }
    security = {
      name      = "Security"
      parent_id = "r-abc123"
    }
  }
  
  # Service Control Policies
  service_control_policies = {
    deny_root_user = {
      name        = "DenyRootUser"
      description = "Prevent root user access"
      content     = file("${path.module}/policies/deny-root-user.json")
      targets     = ["ou-abc-production"]
    }
  }
  
  # Delegated administration
  enable_guardduty_delegated_admin        = true
  guardduty_delegated_admin_account_id    = "222222222222"
  
  # Common configuration
  prefix          = "my-company"
  enabled_regions = ["us-east-1"]
  vpc_cidr        = "10.0.0.0/16"
  
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | >= 5.0, < 6.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0, < 6.0 |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| networking | ./modules/networking | VPC, subnets, routing, Transit Gateway |
| iam | ./modules/iam | IAM policies, roles, Access Analyzer |
| security | ./modules/security | GuardDuty, Security Hub, Config, Macie |
| logging | ./modules/logging | CloudTrail, CloudWatch, S3 logging |
| organization | ./modules/organization | AWS Organizations, OUs, SCPs |

## Inputs

### Deployment Mode

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| deployment_mode | Deployment mode: 'single-account' or 'organization' | `string` | `"single-account"` | no |

### Organization Mode Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| organization_id | AWS Organization ID (required in org mode) | `string` | `null` | conditional |
| organization_root_id | Root OU ID (required in org mode) | `string` | `null` | conditional |
| organizational_units | Map of OUs to create | `map(object)` | `{}` | no |
| service_control_policies | Map of SCPs to create | `map(object)` | `{}` | no |

### Single-Account Mode Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account_id | AWS Account ID (required in single mode) | `string` | `null` | conditional |
| account_alias | IAM account alias | `string` | `null` | no |

### Common Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| prefix | Prefix for resource names | `string` | `"landing-zone"` | no |
| enabled_regions | AWS regions to enable | `list(string)` | `["us-east-1"]` | no |
| tags | Common tags for all resources | `map(string)` | See variables.tf | no |

See [variables.tf](variables.tf) for complete input documentation.

## Outputs

### Common Outputs

- `deployment_mode` - Active deployment mode
- `region` - Primary AWS region
- `account_id` - AWS Account ID
- `kms_key_arn` - KMS key ARN for encryption

### Mode-Specific Outputs

- `organization` - Organization details (org mode only)
- `account` - Account details (single-account mode only)
- `networking` - VPC and networking resources
- `security` - Security service details
- `logging` - Logging configuration

See [outputs.tf](outputs.tf) for complete output documentation.

## Examples

### Configuration Examples

- [**Simple**](examples/simple/) - Minimal single-account deployment (~$40/month)
- [**Complete**](examples/complete/) - Full-featured single-account with all services (~$125/month)
- [**Multi-Account**](examples/multi-account/) - Organization mode with OUs and SCPs

### Policy Examples

- [**SCP Library**](docs/scp-examples.md) - Pre-built Service Control Policies with examples for:
  - Geographic restrictions
  - Security baseline enforcement
  - Cost control
  - Data protection
  - Compliance requirements

## Testing

This module includes comprehensive testing at multiple levels:

### Terraform Native Unit Tests

Fast unit tests that validate configuration logic without deploying to AWS:

```bash
# Run all unit tests
terraform init
terraform test

# Run specific test
terraform test -filter=tests/single-account-mode.tftest.hcl
```

Tests validate:
- Deployment mode requirements
- Variable validation rules
- Conditional resource logic
- Output calculations

### Terratest Integration Tests

Go-based integration tests that deploy real infrastructure to AWS:

```bash
# Install dependencies
cd test
go mod download

# Run all integration tests
go test -v -timeout 60m

# Run specific test
go test -v -timeout 30m -run TestSimpleExampleSingleAccount
```

Integration tests validate:
- VPC configuration (subnets, routing, NAT Gateway)
- Security services (GuardDuty, Security Hub, Config)
- Logging services (CloudTrail, CloudWatch)
- IAM configuration (Access Analyzer, password policy)

⚠️ **Note**: Integration tests create real AWS resources and will incur costs (~$0.50-$2 per test run).

### CI/CD Testing

Automated testing runs on every PR:
- Terraform format check
- Terraform validation
- TFLint scanning
- Unit tests
- Checkov security scanning

Nightly integration tests run in AWS to catch regressions.

## Migration Guide

### From Single-Account to Organization Mode

1. Create AWS Organization in your management account
2. Update Terraform configuration:

```hcl
# Before
deployment_mode = "single-account"
account_id      = "123456789012"

# After
deployment_mode    = "organization"
organization_id    = "o-1234567890"
organization_root_id = "r-abc123"
```

3. Review the plan: `terraform plan`
4. Apply changes incrementally if needed

## Cost Considerations

This module deploys AWS services that may incur costs:

- **Free Tier**: GuardDuty (30 days), Security Hub (30 days), IAM Access Analyzer
- **Minimal Cost**: CloudTrail, VPC Flow Logs, CloudWatch Logs
- **Variable Cost**: NAT Gateway ($0.045/hour + data transfer), AWS Config ($0.003/rule/region)
- **Optional**: Macie (disabled by default), Transit Gateway (disabled by default)

**Cost Optimization Tips**:
- Set `single_nat_gateway = true` for dev environments
- Set `enable_config = false` in cost-sensitive scenarios
- Use `cloudwatch_log_retention_days = 30` for shorter retention

## Security

For security concerns, please review [SECURITY.md](SECURITY.md).

## Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

## License

This module is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.

## Authors

Maintained by [Your Name/Organization]

## Acknowledgments

Based on AWS Well-Architected Framework and security best practices from:
- AWS Control Tower
- CIS AWS Foundations Benchmark
- AWS Security Hub standards
