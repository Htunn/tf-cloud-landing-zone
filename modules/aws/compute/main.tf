# ============================================================================
# Compute Module - ECS, Lambda baseline, EC2
# ============================================================================

data "aws_region" "current" {}

# ============================================================================
# ECS Cluster with Fargate Capacity Providers
# ============================================================================

resource "aws_ecs_cluster" "main" {
  count = var.enable_ecs ? 1 : 0

  name = coalesce(var.ecs_cluster_name, "${var.prefix}-cluster")

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(
    var.tags,
    {
      Name = coalesce(var.ecs_cluster_name, "${var.prefix}-cluster")
    }
  )
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  count = var.enable_ecs ? 1 : 0

  cluster_name       = aws_ecs_cluster.main[0].name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# ============================================================================
# Lambda Execution IAM Role and Log Group (Baseline)
# ============================================================================

resource "aws_iam_role" "lambda_execution" {
  count = var.enable_lambda_baseline ? 1 : 0

  name = "${var.prefix}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLambdaAssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  count      = var.enable_lambda_baseline ? 1 : 0
  role       = aws_iam_role.lambda_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  count      = var.enable_lambda_baseline ? 1 : 0
  role       = aws_iam_role.lambda_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_cloudwatch_log_group" "lambda" {
  count = var.enable_lambda_baseline ? 1 : 0

  name              = "/aws/lambda/${var.prefix}"
  retention_in_days = var.lambda_log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-lambda-logs"
    }
  )
}

# ============================================================================
# EC2 Security Group and Launch Template
# ============================================================================

resource "aws_security_group" "ec2" {
  count = var.enable_ec2 ? 1 : 0

  name        = "${var.prefix}-ec2-sg"
  description = "Security group for EC2 instances managed by ${var.prefix}"
  vpc_id      = var.vpc_id

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
      Name = "${var.prefix}-ec2-sg"
    }
  )
}

resource "aws_launch_template" "main" {
  count = var.enable_ec2 ? 1 : 0

  name_prefix            = "${var.prefix}-lt-"
  image_id               = var.ec2_ami_id
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = [aws_security_group.ec2[0].id]

  # IMDSv2 required — prevents SSRF-based metadata credential theft
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = true
  }

  dynamic "block_device_mappings" {
    for_each = var.kms_key_arn != null ? [1] : []
    content {
      device_name = "/dev/xvda"
      ebs {
        encrypted  = true
        kms_key_id = var.kms_key_arn
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-launch-template"
    }
  )
}

# ============================================================================
# Auto Scaling Group
# ============================================================================

resource "aws_autoscaling_group" "main" {
  count = var.enable_ec2 && var.enable_asg ? 1 : 0

  name                = "${var.prefix}-asg"
  min_size            = var.ec2_min_size
  max_size            = var.ec2_max_size
  desired_capacity    = var.ec2_desired_capacity
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.main[0].id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.prefix}-asg-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
