# ============================================================================
# Database Module - RDS Aurora Serverless v2 and DynamoDB
# ============================================================================

data "aws_region" "current" {}

locals {
  db_port            = var.db_engine == "aurora-postgresql" ? 5432 : 3306
  cluster_identifier = coalesce(var.db_cluster_identifier, "${var.prefix}-db-cluster")
}

# ============================================================================
# RDS - Aurora Serverless v2
# ============================================================================

resource "aws_db_subnet_group" "main" {
  count = var.enable_rds ? 1 : 0

  name       = "${var.prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-db-subnet-group"
    }
  )
}

resource "aws_security_group" "rds" {
  count = var.enable_rds ? 1 : 0

  name        = "${var.prefix}-rds-sg"
  description = "Security group for RDS Aurora cluster in ${var.prefix}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      description = "Allow DB access from approved CIDR blocks"
      from_port   = local.db_port
      to_port     = local.db_port
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-rds-sg"
    }
  )
}

resource "aws_rds_cluster" "main" {
  count = var.enable_rds ? 1 : 0

  cluster_identifier     = local.cluster_identifier
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  engine_mode            = "provisioned"
  database_name          = var.db_name
  master_username        = var.db_master_username
  master_password        = var.db_master_password
  db_subnet_group_name   = aws_db_subnet_group.main[0].name
  vpc_security_group_ids = [aws_security_group.rds[0].id]

  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  deletion_protection       = var.enable_deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.cluster_identifier}-final-snapshot"

  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window

  serverlessv2_scaling_configuration {
    min_capacity = var.db_min_capacity
    max_capacity = var.db_max_capacity
  }

  enabled_cloudwatch_logs_exports = var.db_engine == "aurora-postgresql" ? ["postgresql"] : ["audit", "error", "general", "slowquery"]

  tags = merge(
    var.tags,
    {
      Name = local.cluster_identifier
    }
  )
}

resource "aws_rds_cluster_instance" "main" {
  count = var.enable_rds ? var.db_instance_count : 0

  identifier         = "${local.cluster_identifier}-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.main[0].id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.main[0].engine
  engine_version     = aws_rds_cluster.main[0].engine_version

  auto_minor_version_upgrade = true

  performance_insights_enabled    = var.enable_performance_insights
  performance_insights_kms_key_id = var.enable_performance_insights ? var.kms_key_arn : null

  tags = merge(
    var.tags,
    {
      Name = "${local.cluster_identifier}-instance-${count.index + 1}"
    }
  )
}

# ============================================================================
# DynamoDB Table
# ============================================================================

resource "aws_dynamodb_table" "main" {
  count = var.enable_dynamodb ? 1 : 0

  name         = coalesce(var.dynamodb_table_name, "${var.prefix}-table")
  billing_mode = var.dynamodb_billing_mode
  hash_key     = var.dynamodb_hash_key
  range_key    = var.dynamodb_range_key

  attribute {
    name = var.dynamodb_hash_key
    type = var.dynamodb_hash_key_type
  }

  dynamic "attribute" {
    for_each = var.dynamodb_range_key != null ? [1] : []
    content {
      name = var.dynamodb_range_key
      type = var.dynamodb_range_key_type
    }
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  tags = merge(
    var.tags,
    {
      Name = coalesce(var.dynamodb_table_name, "${var.prefix}-table")
    }
  )
}
