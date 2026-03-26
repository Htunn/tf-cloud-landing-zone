# AWS Cloud Landing Zone - Architecture Diagrams

This document contains comprehensive diagrams illustrating the architecture, deployment flow, and interactions within the AWS Cloud Landing Zone.

## Table of Contents

1. [Deployment Flow Diagram](#deployment-flow-diagram)
2. [Component Architecture Diagram](#component-architecture-diagram)
3. [Deployment Sequence Diagram](#deployment-sequence-diagram)
4. [Organization Mode Architecture](#organization-mode-architecture)
5. [Security Services Interaction](#security-services-interaction)

---

## Deployment Flow Diagram

This flowchart shows the decision flow and deployment process for the landing zone.

```mermaid
flowchart TD
    Start([Start Deployment]) --> CheckMode{Select<br/>Deployment Mode?}
    
    CheckMode -->|Single Account| ValidateSingle[Validate Account ID<br/>& Region]
    CheckMode -->|Organization| ValidateOrg[Validate Org ID,<br/>Root ID & Regions]
    
    ValidateSingle --> CheckServices{Enable<br/>Services?}
    ValidateOrg --> CheckOrgServices{Enable<br/>Services?}
    
    CheckServices -->|Networking| DeployVPC[Deploy VPC<br/>Multi-AZ Subnets<br/>NAT Gateway]
    CheckServices -->|Security| DeploySecurity[Deploy GuardDuty<br/>Security Hub<br/>Config]
    CheckServices -->|Logging| DeployLogging[Deploy CloudTrail<br/>CloudWatch Logs<br/>S3 Buckets]
    CheckServices -->|IAM| DeployIAM[Deploy Password Policy<br/>Access Analyzer<br/>Roles]
    
    CheckOrgServices -->|Networking| DeployOrgVPC[Deploy VPC<br/>Transit Gateway<br/>Multi-Account]
    CheckOrgServices -->|Security| DeployOrgSecurity[Deploy Org GuardDuty<br/>Org Security Hub<br/>Org Config]
    CheckOrgServices -->|Logging| DeployOrgLogging[Deploy Org CloudTrail<br/>Centralized Logging]
    CheckOrgServices -->|IAM| DeployOrgIAM[Deploy Org IAM<br/>Cross-Account Roles]
    CheckOrgServices -->|Organization| DeployOUs[Create OUs<br/>Apply SCPs]
    
    DeployVPC --> NetworkDone{NAT Gateway<br/>Mode?}
    NetworkDone -->|Single| SingleNAT[Deploy 1 NAT Gateway]
    NetworkDone -->|Multi-AZ| MultiNAT[Deploy NAT per AZ]
    
    SingleNAT --> SecurityCheck{Security<br/>Complete?}
    MultiNAT --> SecurityCheck
    DeploySecurity --> SecurityCheck
    DeployLogging --> SecurityCheck
    DeployIAM --> SecurityCheck
    
    DeployOrgVPC --> OrgSecurityCheck{Organization<br/>Services Complete?}
    DeployOrgSecurity --> OrgSecurityCheck
    DeployOrgLogging --> OrgSecurityCheck
    DeployOrgIAM --> OrgSecurityCheck
    DeployOUs --> OrgSecurityCheck
    
    SecurityCheck -->|Yes| RunTests{Run<br/>Tests?}
    OrgSecurityCheck -->|Yes| RunTests
    
    RunTests -->|Unit Tests| TerraformTest[terraform test]
    RunTests -->|Integration| TerratestRun[go test]
    RunTests -->|Skip| Deploy
    
    TerraformTest --> TestPass{Tests Pass?}
    TerratestRun --> TestPass
    
    TestPass -->|Yes| Deploy[terraform apply]
    TestPass -->|No| FixIssues[Fix Issues]
    FixIssues --> Start
    
    Deploy --> Validate[Validate Deployment]
    Validate --> ValidateResults{Validation<br/>Success?}
    
    ValidateResults -->|Yes| Complete([Deployment Complete])
    ValidateResults -->|No| Rollback[terraform destroy]
    Rollback --> Start
    
    style Start fill:#90EE90
    style Complete fill:#90EE90
    style CheckMode fill:#FFD700
    style CheckServices fill:#87CEEB
    style CheckOrgServices fill:#87CEEB
    style TestPass fill:#FFD700
    style ValidateResults fill:#FFD700
    style DeployVPC fill:#DDA0DD
    style DeploySecurity fill:#F08080
    style DeployLogging fill:#20B2AA
    style DeployIAM fill:#FFA07A
    style DeployOUs fill:#9370DB
```

---

## Component Architecture Diagram

This C4 Component diagram shows the internal structure of the landing zone module.

```mermaid
C4Component
    title Component Diagram - AWS Cloud Landing Zone Module

    Container_Boundary(root, "Root Module") {
        Component(main, "Main Orchestrator", "Terraform", "Coordinates all submodules based on deployment mode")
        Component(locals, "Feature Flags", "Terraform Locals", "Calculates conditional logic and feature toggles")
        Component(validation, "Input Validator", "Terraform Variables", "Validates all input parameters")
    }

    Container_Boundary(networking, "Networking Module") {
        Component(vpc, "VPC Manager", "Terraform", "Creates VPC, subnets, route tables")
        Component(nat, "NAT Gateway", "Terraform", "Manages NAT Gateways (single/multi-AZ)")
        Component(tgw, "Transit Gateway", "Terraform", "Creates Transit Gateway for org mode")
        Component(endpoints, "VPC Endpoints", "Terraform", "S3 and DynamoDB endpoints")
    }

    Container_Boundary(security, "Security Module") {
        Component(guardduty, "GuardDuty", "Terraform", "Threat detection service")
        Component(securityhub, "Security Hub", "Terraform", "Central security findings")
        Component(config, "AWS Config", "Terraform", "Compliance monitoring")
        Component(macie, "Macie", "Terraform", "Data discovery (optional)")
    }

    Container_Boundary(logging, "Logging Module") {
        Component(cloudtrail, "CloudTrail", "Terraform", "API logging (org-aware)")
        Component(cloudwatch, "CloudWatch Logs", "Terraform", "Centralized log aggregation")
        Component(s3logs, "S3 Log Buckets", "Terraform", "Long-term log storage")
    }

    Container_Boundary(iam, "IAM Module") {
        Component(password, "Password Policy", "Terraform", "IAM password requirements")
        Component(analyzer, "Access Analyzer", "Terraform", "Detect unintended access")
        Component(roles, "Cross-Account Roles", "Terraform", "Security, admin, readonly roles")
    }

    Container_Boundary(org, "Organization Module") {
        Component(ous, "OU Manager", "Terraform", "Creates organizational units")
        Component(scps, "SCP Manager", "Terraform", "Creates and attaches SCPs")
    }

    System_Ext(aws, "AWS APIs", "AWS Cloud Services")

    Rel(main, locals, "Uses", "Calculates features")
    Rel(main, validation, "Uses", "Validates inputs")
    Rel(main, networking, "Deploys")
    Rel(main, security, "Deploys")
    Rel(main, logging, "Deploys")
    Rel(main, iam, "Deploys")
    Rel(main, org, "Deploys", "org mode only")

    Rel(vpc, aws, "Creates", "VPC API")
    Rel(nat, aws, "Creates", "EC2 API")
    Rel(tgw, aws, "Creates", "EC2 API")
    Rel(endpoints, aws, "Creates", "EC2 API")

    Rel(guardduty, aws, "Enables", "GuardDuty API")
    Rel(securityhub, aws, "Enables", "SecurityHub API")
    Rel(config, aws, "Enables", "Config API")
    Rel(macie, aws, "Enables", "Macie API")

    Rel(cloudtrail, aws, "Creates", "CloudTrail API")
    Rel(cloudwatch, aws, "Creates", "Logs API")
    Rel(s3logs, aws, "Creates", "S3 API")

    Rel(password, aws, "Sets", "IAM API")
    Rel(analyzer, aws, "Creates", "IAM API")
    Rel(roles, aws, "Creates", "IAM API")

    Rel(ous, aws, "Creates", "Organizations API")
    Rel(scps, aws, "Creates", "Organizations API")

    UpdateRelStyle(main, networking, $offsetY="-30")
    UpdateRelStyle(main, security, $offsetX="40")
    UpdateRelStyle(main, logging, $offsetX="-40")
    UpdateRelStyle(main, iam, $offsetY="30")
```

---

## Deployment Sequence Diagram

This sequence diagram shows the interaction between Terraform, the module, and AWS during deployment.

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant TF as Terraform
    participant Root as Root Module
    participant Locals as Locals/Validation
    participant Net as Networking Module
    participant Sec as Security Module
    participant Log as Logging Module
    participant IAM as IAM Module
    participant Org as Organization Module
    participant AWS as AWS APIs

    User->>TF: terraform init
    TF->>Root: Initialize providers
    Root-->>TF: Ready

    User->>TF: terraform plan
    TF->>Root: Load configuration
    Root->>Locals: Calculate feature flags
    
    alt Single Account Mode
        Locals-->>Root: is_single_account = true
        Note over Root,Org: Organization module skipped
    else Organization Mode
        Locals-->>Root: is_organization_mode = true
        Note over Root,Org: All modules enabled
    end

    Root->>Locals: Validate inputs
    Locals-->>Root: Validation passed
    
    Root->>Net: Plan VPC resources
    Net->>AWS: Check VPC limits
    AWS-->>Net: Limits OK
    Net-->>Root: VPC plan ready
    
    Root->>Sec: Plan security services
    Sec->>AWS: Check service quotas
    AWS-->>Sec: Quotas OK
    Sec-->>Root: Security plan ready
    
    Root->>Log: Plan logging resources
    Log->>AWS: Check S3 bucket availability
    AWS-->>Log: Bucket names available
    Log-->>Root: Logging plan ready
    
    Root->>IAM: Plan IAM resources
    IAM->>AWS: Check IAM limits
    AWS-->>IAM: Limits OK
    IAM-->>Root: IAM plan ready
    
    opt Organization Mode Only
        Root->>Org: Plan OUs and SCPs
        Org->>AWS: Check org structure
        AWS-->>Org: Org ready
        Org-->>Root: Org plan ready
    end
    
    TF-->>User: Plan complete (review)

    User->>TF: terraform apply
    
    rect rgb(200, 230, 255)
        Note over TF,AWS: Networking Deployment
        TF->>Net: Deploy VPC
        Net->>AWS: Create VPC
        AWS-->>Net: VPC created
        Net->>AWS: Create Subnets
        AWS-->>Net: Subnets created
        Net->>AWS: Create NAT Gateway(s)
        AWS-->>Net: NAT Gateway(s) ready
        Net-->>TF: Networking complete
    end
    
    rect rgb(255, 230, 230)
        Note over TF,AWS: Security Services Deployment
        TF->>Sec: Deploy security services
        par GuardDuty
            Sec->>AWS: Enable GuardDuty
            AWS-->>Sec: GuardDuty enabled
        and Security Hub
            Sec->>AWS: Enable Security Hub
            AWS-->>Sec: Security Hub enabled
        and AWS Config
            Sec->>AWS: Enable Config
            AWS-->>Sec: Config enabled
        end
        Sec-->>TF: Security services ready
    end
    
    rect rgb(230, 255, 230)
        Note over TF,AWS: Logging Deployment
        TF->>Log: Deploy logging
        Log->>AWS: Create CloudTrail
        AWS-->>Log: CloudTrail ready
        Log->>AWS: Create CloudWatch Logs
        AWS-->>Log: Logs ready
        Log->>AWS: Create S3 buckets
        AWS-->>Log: Buckets created
        Log-->>TF: Logging complete
    end
    
    rect rgb(255, 240, 200)
        Note over TF,AWS: IAM Configuration
        TF->>IAM: Configure IAM
        IAM->>AWS: Set password policy
        AWS-->>IAM: Policy set
        IAM->>AWS: Create Access Analyzer
        AWS-->>IAM: Analyzer ready
        IAM->>AWS: Create cross-account roles
        AWS-->>IAM: Roles created
        IAM-->>TF: IAM complete
    end
    
    opt Organization Mode
        rect rgb(230, 230, 255)
            Note over TF,AWS: Organization Setup
            TF->>Org: Deploy organization
            Org->>AWS: Create OUs
            AWS-->>Org: OUs created
            Org->>AWS: Create SCPs
            AWS-->>Org: SCPs created
            Org->>AWS: Attach SCPs to OUs
            AWS-->>Org: SCPs attached
            Org-->>TF: Organization complete
        end
    end
    
    TF->>Root: Collect outputs
    Root-->>TF: All outputs ready
    TF-->>User: Deployment complete
    
    User->>TF: terraform output
    TF-->>User: Display outputs
```

---

## Organization Mode Architecture

This diagram shows the multi-account organization structure.

```mermaid
flowchart TB
    subgraph AWS["AWS Organization"]
        Root[("Root OU<br/>Management Account")]
        
        Root --> Security["Security OU"]
        Root --> Infra["Infrastructure OU"]
        Root --> Workloads["Workloads OU"]
        Root --> Suspended["Suspended OU"]
        
        Security --> SecTools["Security Tooling<br/>Account"]
        Security --> LogArch["Log Archive<br/>Account"]
        
        Infra --> Shared["Shared Services<br/>Account"]
        
        Workloads --> Prod["Production OU"]
        Workloads --> NonProd["Non-Production OU"]
        
        Prod --> ProdApp1["Prod App 1<br/>Account"]
        Prod --> ProdApp2["Prod App 2<br/>Account"]
        
        NonProd --> Dev["Dev<br/>Account"]
        NonProd --> Test["Test<br/>Account"]
        
        Suspended --> Decomm["Decommissioned<br/>Accounts"]
    end
    
    subgraph SCPs["Service Control Policies"]
        SCP1["Full AWS Access"]
        SCP2["Deny Region Access"]
        SCP3["Require MFA"]
        SCP4["Prevent Root User"]
        SCP5["Deny S3 Public"]
        SCP6["Deny All (Suspended)"]
    end
    
    subgraph TGW["Transit Gateway"]
        TGW1["Central TGW<br/>in Shared Services"]
        TGW1 -.->|Attachment| VPC1["Security VPC"]
        TGW1 -.->|Attachment| VPC2["Shared VPC"]
        TGW1 -.->|Attachment| VPC3["Prod VPC"]
        TGW1 -.->|Attachment| VPC4["Dev VPC"]
    end
    
    subgraph SecServices["Security Services"]
        GD["GuardDuty<br/>(Delegated Admin)"]
        SH["Security Hub<br/>(Delegated Admin)"]
        CF["AWS Config<br/>(Aggregator)"]
    end
    
    SCP1 -.->|Attached| Root
    SCP2 -.->|Attached| Workloads
    SCP2 -.->|Attached| Infra
    SCP3 -.->|Attached| Prod
    SCP4 -.->|Attached| Security
    SCP4 -.->|Attached| Workloads
    SCP5 -.->|Attached| Root
    SCP6 -.->|Attached| Suspended
    
    SecTools -.->|Manages| GD
    SecTools -.->|Manages| SH
    SecTools -.->|Aggregates| CF
    
    LogArch -.->|Stores| CT["CloudTrail Logs"]
    LogArch -.->|Stores| FL["VPC Flow Logs"]
    LogArch -.->|Stores| CW["CloudWatch Logs"]
    
    style Root fill:#FFD700
    style Security fill:#F08080
    style Infra fill:#87CEEB
    style Workloads fill:#90EE90
    style Suspended fill:#D3D3D3
    style TGW1 fill:#DDA0DD
    style GD fill:#FF6347
    style SH fill:#FF6347
    style CF fill:#FF6347
```

---

## Security Services Interaction

This sequence diagram shows how security services interact and aggregate findings.

```mermaid
sequenceDiagram
    autonumber
    participant VPC as VPC Resources
    participant GD as GuardDuty
    participant CF as AWS Config
    participant CT as CloudTrail
    participant SH as Security Hub
    participant CW as CloudWatch
    participant SNS as SNS Topic
    participant Admin as Security Team

    Note over VPC,Admin: Continuous Monitoring

    VPC->>CT: API calls logged
    CT->>CW: Stream logs
    CW->>SNS: Alert on patterns
    
    VPC->>GD: Network traffic analyzed
    GD->>GD: ML threat detection
    
    alt Threat Detected
        GD->>SH: Send finding
        GD->>SNS: Critical alert
        SNS->>Admin: Notify team
    end
    
    VPC->>CF: Resource changes
    CF->>CF: Evaluate rules
    
    alt Non-Compliant
        CF->>SH: Send finding
        CF->>SNS: Compliance alert
        SNS->>Admin: Notify team
    end
    
    rect rgb(200, 230, 255)
        Note over SH: Security Hub Aggregation
        loop Every 15 minutes
            SH->>GD: Fetch findings
            SH->>CF: Fetch findings
            SH->>SH: Correlate findings
            SH->>SH: Apply standards<br/>(CIS, AWS Foundational)
        end
    end
    
    Admin->>SH: View dashboard
    SH-->>Admin: Aggregated findings
    
    Admin->>GD: Investigate threat
    GD-->>Admin: Detailed analysis
    
    Admin->>CF: Review compliance
    CF-->>Admin: Resource timeline
    
    Admin->>CT: Audit trail
    CT-->>Admin: API call history
    
    Note over VPC,Admin: Continuous compliance and threat monitoring
```

---

## Testing Flow

This flowchart shows the testing strategy for the module.

```mermaid
flowchart LR
    Start([Code Change]) --> PreCommit{Pre-commit<br/>Hooks}
    
    PreCommit -->|Format| TFFmt[terraform fmt]
    PreCommit -->|Validate| TFValidate[terraform validate]
    PreCommit -->|Lint| TFLint[tflint]
    PreCommit -->|Docs| TFDocs[terraform-docs]
    
    TFFmt --> LocalTest{Local<br/>Testing}
    TFValidate --> LocalTest
    TFLint --> LocalTest
    TFDocs --> LocalTest
    
    LocalTest -->|Unit Tests| UnitTest[terraform test]
    UnitTest --> UnitPass{Pass?}
    
    UnitPass -->|Yes| GitPush[git push]
    UnitPass -->|No| Fix1[Fix Issues]
    Fix1 --> Start
    
    GitPush --> PR[Create PR]
    
    PR --> CIChecks{CI/CD<br/>Checks}
    
    CIChecks --> CIFmt[Format Check]
    CIChecks --> CIValidate[Validate]
    CIChecks --> CILint[TFLint]
    CIChecks --> CITest[Unit Tests]
    CIChecks --> CISec[Checkov Security]
    
    CIFmt --> CIPass{All Pass?}
    CIValidate --> CIPass
    CILint --> CIPass
    CITest --> CIPass
    CISec --> CIPass
    
    CIPass -->|No| Fix2[Fix Issues]
    Fix2 --> Start
    
    CIPass -->|Yes| Merge[Merge to Main]
    
    Merge --> Nightly{Nightly<br/>Schedule}
    
    Nightly -->|2 AM UTC| IntTest[Integration Tests<br/>Terratest]
    IntTest --> Deploy[Deploy to AWS]
    Deploy --> Validate[Validate Resources]
    Validate --> Cleanup[Cleanup Resources]
    
    Cleanup --> IntPass{Pass?}
    IntPass -->|No| Issue[Create GitHub Issue]
    IntPass -->|Yes| Complete([Tests Complete])
    
    Issue --> Alert[Alert Team]
    Alert --> Complete
    
    style Start fill:#90EE90
    style Complete fill:#90EE90
    style UnitPass fill:#FFD700
    style CIPass fill:#FFD700
    style IntPass fill:#FFD700
    style Fix1 fill:#F08080
    style Fix2 fill:#F08080
    style Deploy fill:#87CEEB
    style Validate fill:#DDA0DD
```

---

## Usage Notes

### Viewing Diagrams

These Mermaid diagrams can be viewed:
1. **In GitHub**: Automatically rendered in markdown files
2. **In VS Code**: Use the Mermaid Preview extension
3. **Online**: Copy to [Mermaid Live Editor](https://mermaid.live/)

### Diagram Types

- **Flowchart**: Shows decision flows and processes
- **C4 Component**: Shows internal module structure
- **Sequence Diagram**: Shows time-ordered interactions
- **Organization Diagram**: Shows AWS account hierarchy

### Customization

To modify these diagrams:
1. Edit the mermaid code blocks
2. Test in Mermaid Live Editor
3. Commit changes to repository

### Related Documentation

- [README.md](../README.md) - Main module documentation
- [examples/](../examples/) - Deployment examples
- [SCP Examples](scp-examples.md) - Service Control Policies
