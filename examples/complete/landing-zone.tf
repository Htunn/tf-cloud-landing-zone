module "landing_zone" {
  source = "../../"

  # Deployment Configuration
  deployment_mode = "single-account"
  account_id      = var.account_id
  
  # Naming and Tagging
  prefix          = var.prefix
  enabled_regions = var.enabled_regions
  
  # VPC Configuration
  vpc_cidr                     = var.vpc_cidr
  availability_zones           = var.availability_zones
  public_subnet_cidrs          = var.public_subnet_cidrs
  private_subnet_cidrs         = var.private_subnet_cidrs
  enable_nat_gateway           = true
  single_nat_gateway           = false  # Multi-AZ NAT for HA
  enable_multi_az_nat_gateway  = true
  enable_vpn_gateway           = false
  
  # VPC Flow Logs
  enable_flow_log                      = true
  flow_log_destination_type            = "cloud-watch-logs"
  flow_log_cloudwatch_log_group_retention_in_days = 30
  
  # VPC Endpoints
  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true
  
  # Transit Gateway (disabled for single-account)
  enable_transit_gateway = false
  
  # Security Services
  enable_guardduty    = true
  enable_security_hub = true
  enable_config       = true
  enable_macie        = true  # Enable Macie for sensitive data discovery
  
  # GuardDuty Configuration
  guardduty_finding_publishing_frequency = "FIFTEEN_MINUTES"
  guardduty_enable_s3_protection        = true
  guardduty_enable_kubernetes_protection = true
  guardduty_enable_malware_protection   = true
  
  # Security Hub Standards
  security_hub_enable_cis_standard = true
  security_hub_enable_aws_foundational_standard = true
  security_hub_enable_pci_dss_standard = false
  
  # AWS Config
  config_delivery_frequency = "TwentyFour_Hours"
  
  # CloudTrail Configuration
  enable_cloudtrail                = true
  cloudtrail_enable_log_file_validation = true
  cloudtrail_enable_logging        = true
  cloudtrail_include_global_service_events = true
  cloudtrail_is_multi_region_trail = true
  
  # CloudWatch Logs
  cloudwatch_log_retention_days = 30  # 30 days for production
  
  # IAM Configuration
  iam_password_policy = {
    minimum_password_length        = 14
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
  
  # Cross-Account Roles
  security_audit_role_trusted_accounts = var.security_audit_role_trusted_accounts
  admin_role_trusted_accounts          = var.admin_role_trusted_accounts
  read_only_role_trusted_accounts      = var.read_only_role_trusted_accounts
  
  # Permission Boundary
  create_permission_boundary = true
  permission_boundary_name   = "${var.prefix}-permission-boundary"
  
  # KMS Encryption
  kms_key_deletion_window_in_days = 30
  kms_enable_key_rotation         = true
  
  # S3 Configuration for Logs
  log_bucket_lifecycle_rules = {
    transition_to_ia_days      = 90
    transition_to_glacier_days = 180
    expiration_days            = 2555  # 7 years
  }
  
  # Additional Tags
  tags = {
    CostCenter  = var.cost_center
    Owner       = var.owner
    Compliance  = "CIS-AWS-Foundations"
    DataClass   = "Confidential"
  }
}
