# ============================================================================
# IAM Module - Identity & Access Management Configuration
# ============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ============================================================================
# IAM Account Alias
# ============================================================================

resource "aws_iam_account_alias" "main" {
  count = var.account_alias != null ? 1 : 0

  account_alias = var.account_alias
}

# ============================================================================
# IAM Password Policy
# ============================================================================

resource "aws_iam_account_password_policy" "main" {
  minimum_password_length        = var.iam_password_policy.minimum_password_length
  require_lowercase_characters   = var.iam_password_policy.require_lowercase_characters
  require_uppercase_characters   = var.iam_password_policy.require_uppercase_characters
  require_numbers                = var.iam_password_policy.require_numbers
  require_symbols                = var.iam_password_policy.require_symbols
  allow_users_to_change_password = var.iam_password_policy.allow_users_to_change_password
  max_password_age               = var.iam_password_policy.max_password_age
  password_reuse_prevention      = var.iam_password_policy.password_reuse_prevention
}

# ============================================================================
# IAM Access Analyzer
# ============================================================================

resource "aws_accessanalyzer_analyzer" "main" {
  count = var.enable_iam_access_analyzer ? 1 : 0

  analyzer_name = "${var.prefix}-access-analyzer"
  type          = var.deployment_mode == "organization" ? "ORGANIZATION" : "ACCOUNT"

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-access-analyzer"
    }
  )
}

# ============================================================================
# Cross-Account Assume Roles (Organization Mode)
# ============================================================================

# Security Audit Role - Read-only access for security auditing
resource "aws_iam_role" "security_audit" {
  count = var.enable_cross_account_roles ? 1 : 0

  name        = "${var.prefix}-security-audit-role"
  description = "Cross-account role for security auditing"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = var.organization_id
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "security_audit_policy" {
  count      = var.enable_cross_account_roles ? 1 : 0
  role       = aws_iam_role.security_audit[0].name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role_policy_attachment" "security_audit_view_only" {
  count      = var.enable_cross_account_roles ? 1 : 0
  role       = aws_iam_role.security_audit[0].name
  policy_arn = "arn:aws:iam::aws:policy/ViewOnlyAccess"
}

# Administrator Access Role - For centralized admin access
resource "aws_iam_role" "administrator_access" {
  count = var.enable_cross_account_roles ? 1 : 0

  name        = "${var.prefix}-administrator-access-role"
  description = "Cross-account role for administrator access"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = var.organization_id
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "administrator_access_policy" {
  count      = var.enable_cross_account_roles ? 1 : 0
  role       = aws_iam_role.administrator_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Read-Only Access Role
resource "aws_iam_role" "read_only_access" {
  count = var.enable_cross_account_roles ? 1 : 0

  name        = "${var.prefix}-read-only-access-role"
  description = "Cross-account role for read-only access"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = var.organization_id
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "read_only_access_policy" {
  count      = var.enable_cross_account_roles ? 1 : 0
  role       = aws_iam_role.read_only_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# ============================================================================
# IAM Permission Boundary Policy
# ============================================================================

resource "aws_iam_policy" "permission_boundary" {
  name        = "${var.prefix}-permission-boundary"
  description = "Permission boundary to limit maximum permissions for IAM entities"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAllExceptIAMModification"
        Effect = "Allow"
        NotAction = [
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:PutUserPermissionsBoundary",
          "iam:DeleteUserPermissionsBoundary",
          "iam:PutRolePermissionsBoundary",
          "iam:DeleteRolePermissionsBoundary"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyPermissionBoundaryModification"
        Effect = "Deny"
        Action = [
          "iam:DeleteUserPermissionsBoundary",
          "iam:DeleteRolePermissionsBoundary"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}
