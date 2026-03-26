# Azure Cloud Landing Zone - Architecture Diagrams

> **Status: Placeholder** — diagrams will be populated once the Azure landing zone module is implemented.

## Planned Diagrams

1. [Deployment Flow Diagram](#deployment-flow-diagram)
2. [Component Architecture Diagram](#component-architecture-diagram)
3. [Management Group Hierarchy](#management-group-hierarchy)
4. [Security Services Interaction](#security-services-interaction)

---

## Deployment Flow Diagram

```mermaid
flowchart TD
    Start([Start Azure Deployment]) --> CheckScope{Select<br/>Scope?}
    CheckScope -->|Single Subscription| ValidateSub[Validate Subscription ID<br/>& Location]
    CheckScope -->|Management Group| ValidateMG[Validate MG Hierarchy<br/>& Policies]

    ValidateSub --> DeployNetworking[Deploy VNet<br/>Subnets / NSGs<br/>NAT Gateway]
    ValidateSub --> DeploySecurity[Deploy Defender for Cloud<br/>Sentinel / Key Vault]
    ValidateSub --> DeployLogging[Deploy Log Analytics<br/>Diagnostic Settings]
    ValidateSub --> DeployIAM[Deploy RBAC Roles<br/>Conditional Access / PIM]

    ValidateMG --> DeployMGPolicies[Apply Azure Policies<br/>Management Group Scoped]
    ValidateMG --> DeployMGNetworking[Deploy Hub VNet<br/>VPN / ExpressRoute]

    DeployNetworking --> Complete
    DeploySecurity --> Complete
    DeployLogging --> Complete
    DeployIAM --> Complete
    DeployMGPolicies --> Complete
    DeployMGNetworking --> Complete([Deployment Complete])

    style Start fill:#90EE90
    style Complete fill:#90EE90
    style CheckScope fill:#FFD700
```

---

## Management Group Hierarchy

```
Tenant Root Group
└── Landing Zone
    ├── Platform
    │   ├── Identity
    │   ├── Management
    │   └── Connectivity
    └── Workloads
        ├── Production
        ├── Development
        └── Sandbox
```

---

## Azure Security Services

| Service | AWS Equivalent | Status |
|---------|---------------|--------|
| Microsoft Defender for Cloud | GuardDuty + Security Hub | Planned |
| Microsoft Sentinel | CloudWatch + Detective | Planned |
| Azure Policy | AWS Config Rules + SCPs | Planned |
| Azure Key Vault | AWS KMS | Planned |
| Azure AD / Entra ID | IAM + AWS SSO | Planned |
| Network Watcher | VPC Flow Logs | Planned |
| Log Analytics Workspace | CloudWatch Logs | Planned |
