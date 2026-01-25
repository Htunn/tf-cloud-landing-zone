# Example Service Control Policies (SCPs)

This directory contains example Service Control Policies for AWS Organizations. These policies help enforce security and compliance requirements across your organization.

## ⚠️ Important Notes

- **Test Before Applying**: Always test SCPs in a non-production OU first
- **Break Glass Procedures**: Document emergency access procedures before applying restrictive SCPs
- **Management Account**: SCPs do not apply to the management account
- **Order Matters**: Deny policies override Allow policies

## Policy Categories

### Security Baseline Policies

1. **deny-region-access.json** - Geographic restrictions
2. **prevent-root-user.json** - Block root account usage
3. **require-mfa.json** - Enforce MFA for sensitive operations
4. **deny-s3-public-access.json** - Prevent public S3 buckets

### Compliance Policies

5. **require-encryption.json** - Enforce encryption at rest
6. **deny-unencrypted-traffic.json** - Require TLS/SSL
7. **require-tagging.json** - Enforce resource tagging
8. **deny-privilege-escalation.json** - Prevent IAM privilege escalation

### Cost Control Policies

9. **deny-expensive-instances.json** - Block large instance types
10. **require-budget-tags.json** - Enforce cost allocation tags

### Data Protection Policies

11. **deny-unencrypted-volumes.json** - Require EBS encryption
12. **deny-public-rds.json** - Prevent public RDS instances
13. **require-backup.json** - Enforce AWS Backup usage

### Operational Policies

14. **deny-root-account-password.json** - Prevent password changes for root
15. **deny-cloudtrail-deletion.json** - Protect CloudTrail
16. **deny-guardduty-disablement.json** - Protect GuardDuty
17. **deny-config-disablement.json** - Protect AWS Config

## Usage Examples

### Apply to Specific OU

```hcl
service_control_policies = {
  deny_region_access = {
    name        = "DenyRegionAccess"
    description = "Restrict to us-east-1 and us-west-2"
    policy      = file("${path.module}/policies/deny-region-access.json")
    targets     = [aws_organizations_organizational_unit.production.id]
  }
}
```

### Apply to Multiple OUs

```hcl
service_control_policies = {
  prevent_root = {
    name    = "PreventRootUser"
    policy  = file("${path.module}/policies/prevent-root-user.json")
    targets = [
      aws_organizations_organizational_unit.production.id,
      aws_organizations_organizational_unit.development.id,
      aws_organizations_organizational_unit.security.id
    ]
  }
}
```

## Policy Descriptions

### 1. deny-region-access.json
Restricts AWS API calls to approved regions.

**Use Case**: Comply with data residency requirements

**Exceptions**: Global services (IAM, Route53, CloudFront)

### 2. prevent-root-user.json
Blocks all API calls made with root credentials.

**Use Case**: Enforce principle of least privilege

**Emergency Access**: Document break-glass procedure

### 3. require-mfa.json
Requires MFA for destructive operations.

**Use Case**: Prevent accidental or malicious resource deletion

**Affected Actions**: EC2 termination, RDS deletion, S3 bucket deletion

### 4. deny-s3-public-access.json
Prevents creation of public S3 buckets.

**Use Case**: Prevent data leaks

**Scope**: Blocks public ACLs and bucket policies

### 5. require-encryption.json
Enforces encryption at rest for storage services.

**Use Case**: Data protection compliance

**Services**: S3, EBS, RDS, DynamoDB

### 6. deny-unencrypted-traffic.json
Requires TLS/SSL for data in transit.

**Use Case**: Protect data in transit

**Services**: S3, API Gateway, ELB

### 7. require-tagging.json
Enforces mandatory tags on resources.

**Use Case**: Cost allocation and resource management

**Required Tags**: Environment, Owner, CostCenter

### 8. deny-privilege-escalation.json
Prevents IAM privilege escalation techniques.

**Use Case**: Security hardening

**Blocks**: Creating users/roles without MFA, modifying policies without MFA

## Testing SCPs

### Step 1: Create Test OU
```bash
aws organizations create-organizational-unit \
  --parent-id r-xxxx \
  --name "Test-OU"
```

### Step 2: Move Test Account
```bash
aws organizations move-account \
  --account-id 123456789012 \
  --source-parent-id r-xxxx \
  --destination-parent-id ou-xxxx-xxxxxxxx
```

### Step 3: Attach SCP
```bash
aws organizations attach-policy \
  --policy-id p-xxxxxxxx \
  --target-id ou-xxxx-xxxxxxxx
```

### Step 4: Test Access
```bash
# This should fail if SCP is working
aws ec2 run-instances --region eu-west-1 ...
```

### Step 5: Detach and Move Back
```bash
aws organizations detach-policy \
  --policy-id p-xxxxxxxx \
  --target-id ou-xxxx-xxxxxxxx

aws organizations move-account \
  --account-id 123456789012 \
  --source-parent-id ou-xxxx-xxxxxxxx \
  --destination-parent-id r-xxxx
```

## Common Patterns

### Allowlist Approach
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["ec2:*", "s3:*", "rds:*"],
    "Resource": "*"
  }]
}
```

### Denylist Approach (Recommended)
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Deny",
    "Action": ["ec2:RunInstances"],
    "Resource": "*",
    "Condition": {
      "StringEquals": {
        "ec2:InstanceType": ["m5.24xlarge", "m5.16xlarge"]
      }
    }
  }]
}
```

## Best Practices

1. **Start Permissive**: Begin with less restrictive policies
2. **Monitor Impact**: Use CloudTrail to see what's being blocked
3. **Document Exceptions**: Maintain a list of approved exceptions
4. **Regular Review**: Review policies quarterly
5. **Version Control**: Store policies in Git
6. **Test Thoroughly**: Always test in non-production first
7. **Break Glass**: Document emergency procedures
8. **Gradual Rollout**: Apply to dev → staging → production

## Troubleshooting

### Policy Blocks Legitimate Access

**Solution**: Add exception using `StringNotEquals` condition

```json
{
  "Condition": {
    "StringNotEquals": {
      "aws:PrincipalArn": "arn:aws:iam::123456789012:role/AdminRole"
    }
  }
}
```

### Emergency Access Needed

1. Log into management account (SCPs don't apply)
2. Detach SCP from affected OU
3. Complete emergency work
4. Reattach SCP
5. Document incident

### Policy Not Taking Effect

- Check policy syntax in AWS Policy Simulator
- Verify policy is attached to correct OU
- Allow 5-10 minutes for propagation
- Check if account is in correct OU

## Policy Simulator

Test policies before applying:

```bash
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::123456789012:policy/MyPolicy \
  --action-names ec2:RunInstances \
  --resource-arns arn:aws:ec2:us-east-1:123456789012:instance/*
```

## Additional Resources

- [AWS SCP Examples](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_examples.html)
- [SCP Syntax](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_syntax.html)
- [AWS Policy Simulator](https://policysim.aws.amazon.com/)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)

## Contributing

To add new example policies:

1. Create JSON policy file
2. Test in AWS Policy Simulator
3. Validate with `terraform validate`
4. Document use case in this README
5. Submit pull request
