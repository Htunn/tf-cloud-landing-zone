# ============================================================================
# KMS Module - Customer Managed Key Encryption
# ============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ============================================================================
# KMS Customer Managed Key
# ============================================================================

resource "aws_kms_key" "main" {
  count = var.enable_kms_key ? 1 : 0

  description             = "CMK for ${var.prefix} landing zone encryption"
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = true
  multi_region            = var.enable_multi_region

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid    = "EnableRootAccountAccess"
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          }
          Action   = "kms:*"
          Resource = "*"
        }
      ],
      length(var.key_administrators) > 0 ? [
        {
          Sid    = "KeyAdministrators"
          Effect = "Allow"
          Principal = {
            AWS = var.key_administrators
          }
          Action = [
            "kms:Create*",
            "kms:Describe*",
            "kms:Enable*",
            "kms:List*",
            "kms:Put*",
            "kms:Update*",
            "kms:Revoke*",
            "kms:Disable*",
            "kms:Get*",
            "kms:Delete*",
            "kms:TagResource",
            "kms:UntagResource",
            "kms:ScheduleKeyDeletion",
            "kms:CancelKeyDeletion"
          ]
          Resource = "*"
        }
      ] : [],
      length(var.key_users) > 0 ? [
        {
          Sid    = "KeyUsers"
          Effect = "Allow"
          Principal = {
            AWS = var.key_users
          }
          Action = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
          ]
          Resource = "*"
        }
      ] : [],
      [
        {
          Sid    = "AllowAWSServiceUse"
          Effect = "Allow"
          Principal = {
            Service = [
              "cloudtrail.amazonaws.com",
              "logs.${data.aws_region.current.id}.amazonaws.com",
              "s3.amazonaws.com",
              "config.amazonaws.com",
              "ecr.amazonaws.com"
            ]
          }
          Action = [
            "kms:GenerateDataKey*",
            "kms:Decrypt",
            "kms:DescribeKey"
          ]
          Resource = "*"
        }
      ]
    )
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-cmk"
    }
  )
}

# ============================================================================
# KMS Key Alias
# ============================================================================

resource "aws_kms_alias" "main" {
  count = var.enable_kms_key ? 1 : 0

  name          = "alias/${var.kms_key_alias}"
  target_key_id = aws_kms_key.main[0].key_id
}
