# ============================================================================
# ECR Module - Elastic Container Registry
# ============================================================================

data "aws_caller_identity" "current" {}

# ============================================================================
# ECR Repositories
# ============================================================================

resource "aws_ecr_repository" "main" {
  for_each = var.repositories

  name                 = "${var.prefix}-${each.key}"
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.kms_key_arn != null ? "KMS" : "AES256"
    kms_key         = var.kms_key_arn
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-${each.key}"
    }
  )
}

# ============================================================================
# ECR Lifecycle Policies
# ============================================================================

resource "aws_ecr_lifecycle_policy" "main" {
  for_each   = var.repositories
  repository = aws_ecr_repository.main[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after ${var.untagged_image_expiry_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_image_expiry_days
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last ${var.lifecycle_policy_keep_count} tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v", "release", "latest"]
          countType     = "imageCountMoreThan"
          countNumber   = var.lifecycle_policy_keep_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ============================================================================
# ECR Repository Policy (Cross-Account Pull)
# ============================================================================

resource "aws_ecr_repository_policy" "cross_account" {
  for_each   = var.enable_cross_account_pull && length(var.cross_account_ids) > 0 ? var.repositories : {}
  repository = aws_ecr_repository.main[each.key].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountPull"
        Effect = "Allow"
        Principal = {
          AWS = [for id in var.cross_account_ids : "arn:aws:iam::${id}:root"]
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}
