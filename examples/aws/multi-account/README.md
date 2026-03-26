# Multi-Account AWS Landing Zone with Organizations

This example demonstrates a complete AWS Landing Zone deployment using AWS Organizations for multi-account management.

## Features

- ✅ AWS Organizations with hierarchical OUs
- ✅ Service Control Policies (SCPs)
- ✅ Multi-account VPC with Transit Gateway
- ✅ Centralized security services (GuardDuty, Security Hub, Config)
- ✅ Organization-wide CloudTrail
- ✅ Delegated administrator accounts
- ✅ Cross-account IAM roles
- ✅ Centralized logging

## Architecture

### Organization Structure

```
Root
├── Security OU
│   ├── Security Tooling Account
│   └── Log Archive Account
├── Infrastructure OU
│   └── Shared Services Account
├── Workloads OU
│   ├── Production OU
│   │   ├── Prod App Account 1
│   │   └── Prod App Account 2
│   └── Non-Production OU
│       ├── Dev Account
│       └── Test Account
└── Suspended OU
    └── (For decommissioned accounts)
```

### Service Control Policies

1. **FullAWSAccess** - Default policy (Root OU)
2. **DenyRegionAccess** - Restrict to approved regions
3. **RequireMFA** - Enforce MFA for API calls
4. **PreventRootUser** - Prevent root user usage
5. **DenyS3PublicAccess** - Prevent public S3 buckets

## Prerequisites

- AWS Organizations already created
- Management account access
- Terraform >= 1.6.0
- AWS CLI configured

## Cost Estimate

Multi-account setup with 5 member accounts:

| Service | Monthly Cost |
|---------|-------------|
| Transit Gateway | ~$36 |
| Transit Gateway Attachments (5x) | ~$18 |
| NAT Gateways (3 per account) | ~$96/account |
| GuardDuty (org-wide) | ~$20 |
| Security Hub (org-wide) | ~$10 |
| AWS Config (org-wide) | ~$15 |
| CloudTrail (organization) | ~$5 |
| S3 Storage (logs) | ~$10 |
| **Total** | **~$600-800/month** |

*Costs vary based on data transfer and number of accounts*

## Usage

### 1. Prerequisites Setup

First, ensure AWS Organizations is enabled:

```bash
# Check if Organizations is enabled
aws organizations describe-organization
```

If not enabled, create an organization:

```bash
aws organizations create-organization --feature-set ALL
```

### 2. Configure Variables

Copy and customize the variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your organization details:

```hcl
organization_id                = "o-1234567890"
organization_root_id           = "r-abc123"
organization_master_account_id = "111111111111"
```

### 3. Deploy

```bash
# Initialize Terraform
terraform init

# Preview the changes
terraform plan

# Deploy the landing zone
terraform apply
```

### 4. Post-Deployment Steps

After deployment:

1. **Enable Trusted Access**:
   ```bash
   aws organizations enable-aws-service-access \
     --service-principal guardduty.amazonaws.com
   
   aws organizations enable-aws-service-access \
     --service-principal securityhub.amazonaws.com
   
   aws organizations enable-aws-service-access \
     --service-principal config.amazonaws.com
   ```

2. **Delegate Administration**:
   - GuardDuty: Delegate to Security Tooling account
   - Security Hub: Delegate to Security Tooling account
   - AWS Config: Configure aggregator in Security Tooling account

3. **Invite Member Accounts** (if not using AWS Control Tower):
   ```bash
   aws organizations invite-account-to-organization \
     --target Id=222222222222,Type=ACCOUNT
   ```

## Organizational Units

### Security OU
Houses security and compliance workloads:
- **Security Tooling Account**: GuardDuty, Security Hub, Config aggregator
- **Log Archive Account**: Centralized logging, CloudTrail, VPC Flow Logs

### Infrastructure OU
Shared infrastructure services:
- **Shared Services Account**: Transit Gateway, DNS, Active Directory

### Workloads OU
Application workloads organized by environment:
- **Production OU**: Production workloads with strict SCPs
- **Non-Production OU**: Dev/test environments with relaxed policies

### Suspended OU
Quarantine for decommissioned accounts with deny-all SCP

## Service Control Policies

### Deny Region Access
Restricts API calls to approved regions only:
```json
{
  "Effect": "Deny",
  "NotAction": ["iam:*", "organizations:*", "route53:*"],
  "Resource": "*",
  "Condition": {
    "StringNotEquals": {
      "aws:RequestedRegion": ["us-east-1", "us-west-2"]
    }
  }
}
```

### Require MFA
Enforces MFA for sensitive operations:
```json
{
  "Effect": "Deny",
  "Action": ["ec2:StopInstances", "ec2:TerminateInstances"],
  "Resource": "*",
  "Condition": {
    "BoolIfExists": {"aws:MultiFactorAuthPresent": "false"}
  }
}
```

### Prevent Root User
Blocks root user API calls:
```json
{
  "Effect": "Deny",
  "Action": "*",
  "Resource": "*",
  "Condition": {
    "StringLike": {"aws:PrincipalArn": "arn:aws:iam::*:root"}
  }
}
```

## Networking

### Transit Gateway Configuration

- **Hub-and-Spoke**: Central Transit Gateway in Shared Services account
- **VPC Attachments**: Each account VPC attaches to Transit Gateway
- **Route Propagation**: Automatic route propagation between VPCs
- **Segmentation**: Network segmentation using route tables

### IP Address Planning

| Account | VPC CIDR | Purpose |
|---------|----------|---------|
| Shared Services | 10.0.0.0/16 | Transit Gateway, DNS |
| Security | 10.1.0.0/16 | Security tools |
| Log Archive | 10.2.0.0/16 | Log aggregation |
| Production 1 | 10.10.0.0/16 | Prod app 1 |
| Production 2 | 10.11.0.0/16 | Prod app 2 |
| Development | 10.20.0.0/16 | Dev environment |
| Testing | 10.21.0.0/16 | Test environment |

## Security Services

### GuardDuty (Organization)
- **Delegated Admin**: Security Tooling account
- **Auto-Enable**: Automatically enable for new accounts
- **Finding Aggregation**: Centralized findings

### Security Hub (Organization)
- **Delegated Admin**: Security Tooling account
- **Standards**: CIS AWS Foundations + AWS Foundational
- **Aggregation**: Cross-region aggregation
- **Auto-Enable**: Enable for new member accounts

### AWS Config (Organization)
- **Aggregator**: Security Tooling account
- **Rules**: Organization-wide Config rules
- **Conformance Packs**: CIS AWS Foundations pack

## Compliance

This setup helps meet:
- ✅ CIS AWS Foundations Benchmark v1.4.0
- ✅ AWS Well-Architected Framework
- ✅ NIST Cybersecurity Framework
- ✅ PCI DSS requirements (partial)
- ✅ HIPAA compliance controls (partial)

## Customization

### Add New OU

```hcl
organizational_units = {
  sandbox = {
    name      = "Sandbox"
    parent_id = var.organization_root_id
  }
}
```

### Create Custom SCP

```hcl
service_control_policies = {
  deny_large_instances = {
    name        = "DenyLargeInstances"
    description = "Prevent launching large EC2 instances"
    policy      = file("${path.module}/policies/deny-large-instances.json")
    targets     = [module.landing_zone.organizational_units["non_production"].id]
  }
}
```

### Multi-Region Deployment

```hcl
enabled_regions = ["us-east-1", "us-west-2", "eu-west-1"]
```

## Monitoring and Alerts

Set up CloudWatch alarms for:
- Root user login
- Unauthorized API calls
- GuardDuty high severity findings
- Security Hub critical findings
- Config compliance changes

## Disaster Recovery

- **Backup Strategy**: AWS Backup for cross-account backups
- **State Management**: S3 backend with replication
- **Documentation**: Runbooks for account recovery

## Best Practices

1. **Account Isolation**: Separate accounts for different environments
2. **Least Privilege**: Restrictive SCPs by default
3. **Centralized Logging**: All logs to Log Archive account
4. **Network Segmentation**: Transit Gateway route tables
5. **Automated Compliance**: AWS Config rules
6. **Break Glass**: Emergency access procedures documented

## Troubleshooting

### SCP Denying Access
If locked out by SCP:
1. Log in to management account
2. Detach SCP from affected OU
3. Fix policy and reattach

### Transit Gateway Connectivity
```bash
# Check route table associations
aws ec2 describe-transit-gateway-route-tables

# Verify route propagation
aws ec2 get-transit-gateway-route-table-propagations \
  --transit-gateway-route-table-id tgw-rtb-xxx
```

## Next Steps

1. Configure AWS SSO for centralized access
2. Set up AWS Control Tower (optional)
3. Implement account vending machine
4. Configure AWS Backup policies
5. Set up cross-account CI/CD pipelines
6. Implement AWS Service Catalog

## Support

For issues:
- Check [main README](../../README.md)
- Review AWS Organizations [documentation](https://docs.aws.amazon.com/organizations/)
- Open GitHub issue
