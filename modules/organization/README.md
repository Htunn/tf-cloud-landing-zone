# Organization Module

AWS Organizations management module for multi-account environments:

- **Organizational Units**: Hierarchical account organization
- **Service Control Policies**: Organization-wide guardrails
- **Policy Attachments**: Automated SCP enforcement

## Features

- Flexible OU hierarchy
- Multiple SCP support
- Automatic policy attachment
- Tag-based organization

## Usage

```hcl
module "organization" {
  source = "./modules/organization"

  organization_id      = "o-1234567890"
  organization_root_id = "r-abc123"
  
  organizational_units = {
    production = {
      name      = "Production"
      parent_id = "r-abc123"
    }
    development = {
      name      = "Development"
      parent_id = "r-abc123"
    }
  }
  
  service_control_policies = {
    deny_root = {
      name        = "DenyRootUser"
      description = "Deny root user access"
      content     = file("${path.module}/policies/deny-root.json")
      targets     = ["ou-abc-prod123"]
    }
  }
  
  prefix = "my-company"
  tags   = {
    Environment = "management"
  }
}
```
