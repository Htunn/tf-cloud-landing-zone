module "landing_zone" {
  source = "../../../aws"

  # Organization Configuration
  deployment_mode                = "organization"
  organization_id                = var.organization_id
  organization_root_id           = var.organization_root_id
  organization_master_account_id = var.organization_master_account_id

  # Naming and Regions
  prefix          = var.prefix
  enabled_regions = var.enabled_regions

  # Organizational Units
  organizational_units = {
    security = {
      name      = "Security"
      parent_id = var.organization_root_id
    }
    infrastructure = {
      name      = "Infrastructure"
      parent_id = var.organization_root_id
    }
    workloads = {
      name      = "Workloads"
      parent_id = var.organization_root_id
    }
    production = {
      name      = "Production"
      parent_id = module.landing_zone.organizational_units["workloads"].id
    }
    non_production = {
      name      = "Non-Production"
      parent_id = module.landing_zone.organizational_units["workloads"].id
    }
    suspended = {
      name      = "Suspended"
      parent_id = var.organization_root_id
    }
  }

  # Service Control Policies
  service_control_policies = {
    deny_region_access = {
      name        = "DenyRegionAccess"
      description = "Deny access to regions outside approved list"
      policy      = file("${path.module}/policies/deny-region-access.json")
      targets = [
        module.landing_zone.organizational_units["workloads"].id,
        module.landing_zone.organizational_units["infrastructure"].id
      ]
    }
    require_mfa = {
      name        = "RequireMFA"
      description = "Require MFA for sensitive operations"
      policy      = file("${path.module}/policies/require-mfa.json")
      targets = [
        module.landing_zone.organizational_units["production"].id
      ]
    }
    prevent_root_user = {
      name        = "PreventRootUser"
      description = "Prevent root user API calls"
      policy      = file("${path.module}/policies/prevent-root-user.json")
      targets = [
        module.landing_zone.organizational_units["workloads"].id,
        module.landing_zone.organizational_units["infrastructure"].id,
        module.landing_zone.organizational_units["security"].id
      ]
    }
    deny_s3_public_access = {
      name        = "DenyS3PublicAccess"
      description = "Prevent public S3 bucket access"
      policy      = file("${path.module}/policies/deny-s3-public-access.json")
      targets = [
        var.organization_root_id
      ]
    }
    deny_all_suspended = {
      name        = "DenyAllActions"
      description = "Deny all actions for suspended accounts"
      policy      = file("${path.module}/policies/deny-all.json")
      targets = [
        module.landing_zone.organizational_units["suspended"].id
      ]
    }
  }

  # VPC Configuration (for shared services)
  vpc_cidr                    = var.vpc_cidr
  availability_zones          = var.availability_zones
  public_subnet_cidrs         = var.public_subnet_cidrs
  private_subnet_cidrs        = var.private_subnet_cidrs
  enable_nat_gateway          = true
  single_nat_gateway          = false
  enable_multi_az_nat_gateway = true

  # Transit Gateway (organization-wide)
  enable_transit_gateway                          = true
  transit_gateway_description                     = "${var.prefix} Organization Transit Gateway"
  transit_gateway_amazon_side_asn                 = 64512
  transit_gateway_auto_accept_shared_attachments  = "enable"
  transit_gateway_default_route_table_association = "enable"
  transit_gateway_default_route_table_propagation = "enable"
  transit_gateway_dns_support                     = "enable"
  transit_gateway_vpn_ecmp_support                = "enable"

  # Security Services (organization-wide)
  enable_guardduty    = true
  enable_security_hub = true
  enable_config       = true
  enable_macie        = false # Optional, costly at org level

  # GuardDuty Configuration
  guardduty_finding_publishing_frequency = "FIFTEEN_MINUTES"
  guardduty_enable_s3_protection         = true
  guardduty_enable_kubernetes_protection = true
  guardduty_enable_malware_protection    = true

  # Security Hub
  security_hub_enable_cis_standard              = true
  security_hub_enable_aws_foundational_standard = true
  security_hub_enable_pci_dss_standard          = false

  # CloudTrail (organization trail)
  enable_cloudtrail                        = true
  cloudtrail_is_organization_trail         = true
  cloudtrail_enable_log_file_validation    = true
  cloudtrail_include_global_service_events = true
  cloudtrail_is_multi_region_trail         = true

  # CloudWatch Logs
  cloudwatch_log_retention_days = 90 # Longer retention for compliance

  # IAM Configuration
  iam_password_policy = {
    minimum_password_length        = 16
    require_lowercase_characters   = true
    require_uppercase_characters   = true
    require_numbers                = true
    require_symbols                = true
    allow_users_to_change_password = true
    expire_passwords               = true
    max_password_age               = 90
    password_reuse_prevention      = 24
    hard_expiry                    = false
  }

  enable_iam_access_analyzer = true
  iam_access_analyzer_type   = "ORGANIZATION"

  # Cross-Account Roles
  security_audit_role_trusted_accounts = [var.security_account_id]
  admin_role_trusted_accounts          = var.admin_trusted_accounts
  read_only_role_trusted_accounts      = [var.security_account_id]

  # Permission Boundary (organization-wide)
  create_permission_boundary = true
  permission_boundary_name   = "${var.prefix}-org-permission-boundary"

  # KMS Encryption
  kms_key_deletion_window_in_days = 30
  kms_enable_key_rotation         = true

  # S3 Lifecycle for Logs (long retention for compliance)
  log_bucket_lifecycle_rules = {
    transition_to_ia_days      = 90
    transition_to_glacier_days = 365
    expiration_days            = 2555 # 7 years
  }

  # Tags
  tags = {
    Environment  = "organization"
    Compliance   = "CIS-AWS-Foundations"
    DataClass    = "Restricted"
    CostCenter   = var.cost_center
    BusinessUnit = var.business_unit
  }
}
