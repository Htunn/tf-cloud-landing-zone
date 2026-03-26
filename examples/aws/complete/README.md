# Complete AWS Landing Zone Example

This example demonstrates a full-featured AWS Landing Zone deployment in single-account mode with all security and networking services enabled.

## Features Enabled

- ✅ Multi-AZ VPC with public and private subnets
- ✅ NAT Gateway per availability zone (high availability)
- ✅ VPC Flow Logs
- ✅ VPC Endpoints (S3, DynamoDB)
- ✅ Amazon GuardDuty with all protection plans
- ✅ AWS Security Hub (CIS + AWS Foundational standards)
- ✅ AWS Config with compliance rules
- ✅ Amazon Macie for sensitive data discovery
- ✅ CloudTrail with log file validation
- ✅ Centralized logging to S3
- ✅ IAM password policy
- ✅ IAM Access Analyzer
- ✅ Cross-account roles for security auditing

## Architecture

This configuration creates a production-ready security baseline with:

- **Networking**: 3 AZs, 6 subnets (3 public, 3 private), 3 NAT Gateways
- **Security Monitoring**: GuardDuty, Security Hub, Config, Macie
- **Audit Logging**: CloudTrail, CloudWatch Logs, VPC Flow Logs
- **Access Control**: IAM password policy, Access Analyzer, permission boundaries

## Cost Estimate

| Service | Monthly Cost (us-east-1) |
|---------|--------------------------|
| NAT Gateways (3x) | ~$96 |
| GuardDuty | ~$4 |
| Security Hub | ~$0.001/check |
| AWS Config | ~$2 |
| Macie | ~$10 |
| CloudTrail | ~$2 |
| S3 Storage | ~$3 |
| CloudWatch Logs | ~$3 |
| VPC Flow Logs | ~$5 |
| **Total** | **~$125-135/month** |

## Prerequisites

- AWS account with administrative access
- Terraform >= 1.6.0
- AWS CLI configured with credentials

## Usage

### 1. Configure Variables

Copy the example variables file and customize:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific values:

```hcl
account_id = "123456789012"  # Your AWS account ID
prefix     = "mycompany"     # Your organization prefix
```

### 2. Review Configuration

Review the `landing-zone.tf` file to understand what will be deployed.

### 3. Deploy

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy infrastructure
terraform apply
```

### 4. Verify Deployment

After deployment, verify the following in AWS Console:

- **VPC**: Check VPC, subnets, and route tables in us-east-1
- **GuardDuty**: Verify detector is enabled
- **Security Hub**: Check CIS and AWS Foundational standards are enabled
- **Config**: Verify configuration recorder is recording
- **CloudTrail**: Check trail is logging events
- **S3**: Verify CloudTrail and logging buckets exist

## Outputs

The module provides comprehensive outputs including:

- VPC ID and subnet IDs
- Security service ARNs and IDs
- S3 bucket names for logs
- IAM role ARNs

View outputs:

```bash
terraform output
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Note**: S3 buckets with logs may need to be manually emptied before destruction.

## Customization

### Reduce Costs

To reduce costs while maintaining security:

```hcl
# Use single NAT Gateway instead of multi-AZ
enable_multi_az_nat_gateway = false
single_nat_gateway          = true

# Disable Macie
enable_macie = false

# Reduce log retention
cloudwatch_log_retention_days = 7
```

### Enable Additional Regions

```hcl
enabled_regions = ["us-east-1", "us-west-2", "eu-west-1"]
```

### Customize VPC CIDR

```hcl
vpc_cidr = "10.1.0.0/16"  # Change to your preferred CIDR
```

## Security Considerations

This example implements:

1. **Defense in Depth**: Multiple layers of security controls
2. **Least Privilege**: IAM permission boundaries
3. **Audit Logging**: Comprehensive logging of all API calls
4. **Threat Detection**: Real-time monitoring with GuardDuty
5. **Compliance**: Security Hub standards for CIS and AWS best practices
6. **Data Protection**: Encryption at rest with KMS

## Compliance Frameworks

This configuration helps meet requirements for:

- CIS AWS Foundations Benchmark
- AWS Foundational Security Best Practices
- NIST Cybersecurity Framework
- PCI DSS (partial)
- HIPAA (partial)

## Next Steps

After deployment:

1. Review Security Hub findings
2. Configure GuardDuty notifications (SNS)
3. Set up AWS Config rules for your compliance requirements
4. Configure CloudWatch alarms for critical metrics
5. Implement backup policies for critical resources
6. Set up AWS SSO for centralized access management

## Support

For issues or questions:
- Check the [main README](../../README.md)
- Review [troubleshooting guide](../../docs/troubleshooting.md)
- Open an issue on GitHub
