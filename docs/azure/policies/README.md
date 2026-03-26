# Example Azure Policies

> **Status: Placeholder** — Azure Policy examples will be added once the Azure landing zone module is implemented.

## Planned Policy Categories

### Security Baseline
- `deny-public-storage-accounts.json` — Block public blob access
- `require-https-only.json` — Enforce HTTPS on storage and web apps
- `deny-unencrypted-disks.json` — Require managed disk encryption
- `prevent-classic-resources.json` — Block legacy classic resources

### Identity & Access
- `require-mfa-for-privileged-roles.json` — Enforce MFA via Conditional Access
- `deny-non-compliant-resource-locations.json` — Geographic restrictions
- `require-managed-identity.json` — Enforce managed identities over service principals

### Cost Control
- `deny-expensive-vm-skus.json` — Block large/GPU VM SKUs
- `require-budget-tags.json` — Enforce cost allocation tags
- `require-auto-shutdown.json` — Enforce auto-shutdown on dev VMs

### Operational
- `deny-diagnostic-setting-deletion.json` — Protect diagnostic settings
- `require-resource-locks.json` — Enforce azure resource locks on production
- `deny-public-ip-creation.json` — Prevent ad-hoc public IP allocation

## Usage (Planned)

```hcl
# Example: once azure/ module is implemented
module "azure_landing_zone" {
  source = "./azure"

  azure_policies = {
    deny_public_storage = {
      name        = "DenyPublicStorageAccounts"
      description = "Prevent public access on storage accounts"
      policy_file = file("${path.module}/docs/azure/policies/deny-public-storage-accounts.json")
      scope       = "/subscriptions/${var.subscription_id}"
    }
  }
}
```

## Comparison: AWS SCPs vs Azure Policies

| Aspect | AWS SCPs | Azure Policy |
|--------|----------|--------------|
| Scope | Organization / OU / Account | Management Group / Subscription / Resource Group |
| Effect | Allow / Deny (IAM augmented) | Audit / Deny / Append / Modify / DeployIfNotExists |
| Inheritance | Top-down through org tree | Top-down through MG hierarchy |
| Exemptions | Not directly supported | Policy exemptions supported |
| Built-in library | Limited | Extensive (hundreds of built-ins) |
