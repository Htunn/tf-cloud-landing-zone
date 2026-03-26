module "landing_zone" {
  source = "../../../aws"

  # Deployment Mode
  deployment_mode = "single-account"
  account_id      = var.account_id

  # Basic Configuration
  prefix          = "simple-lz"
  enabled_regions = [var.aws_region]

  # Networking
  vpc_cidr           = "10.0.0.0/16"
  enable_nat_gateway = true
  single_nat_gateway = true # Cost optimization - single NAT for all AZs

  # Security Services
  enable_guardduty    = true
  enable_security_hub = true
  enable_config       = false # Disabled to reduce costs
  enable_macie        = false # Disabled by default

  # Logging
  enable_cloudtrail                     = true
  cloudtrail_enable_log_file_validation = true
  cloudwatch_log_retention_days         = 30 # Shorter retention for cost savings

  # IAM
  enable_iam_access_analyzer = true
  account_alias              = var.account_alias

  tags = {
    Example     = "simple"
    Environment = "development"
  }
}
