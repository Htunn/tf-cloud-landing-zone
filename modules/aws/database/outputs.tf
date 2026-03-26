output "rds_cluster_endpoint" {
  description = "Writer endpoint for the RDS Aurora cluster"
  value       = var.enable_rds ? aws_rds_cluster.main[0].endpoint : null
}

output "rds_cluster_reader_endpoint" {
  description = "Read-only endpoint for the RDS Aurora cluster"
  value       = var.enable_rds ? aws_rds_cluster.main[0].reader_endpoint : null
}

output "rds_cluster_id" {
  description = "RDS cluster identifier"
  value       = var.enable_rds ? aws_rds_cluster.main[0].id : null
}

output "rds_cluster_arn" {
  description = "RDS cluster ARN"
  value       = var.enable_rds ? aws_rds_cluster.main[0].arn : null
}

output "rds_security_group_id" {
  description = "Security group ID for the RDS cluster"
  value       = var.enable_rds ? aws_security_group.rds[0].id : null
}

output "rds_subnet_group_name" {
  description = "DB subnet group name for the RDS cluster"
  value       = var.enable_rds ? aws_db_subnet_group.main[0].name : null
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = var.enable_dynamodb ? aws_dynamodb_table.main[0].name : null
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = var.enable_dynamodb ? aws_dynamodb_table.main[0].arn : null
}

output "dynamodb_table_id" {
  description = "DynamoDB table ID"
  value       = var.enable_dynamodb ? aws_dynamodb_table.main[0].id : null
}
