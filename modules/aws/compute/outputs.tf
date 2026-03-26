output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = var.enable_ecs ? aws_ecs_cluster.main[0].arn : null
}

output "ecs_cluster_id" {
  description = "ECS cluster ID"
  value       = var.enable_ecs ? aws_ecs_cluster.main[0].id : null
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = var.enable_ecs ? aws_ecs_cluster.main[0].name : null
}

output "lambda_execution_role_arn" {
  description = "ARN of the shared Lambda execution IAM role"
  value       = var.enable_lambda_baseline ? aws_iam_role.lambda_execution[0].arn : null
}

output "lambda_execution_role_name" {
  description = "Name of the shared Lambda execution IAM role"
  value       = var.enable_lambda_baseline ? aws_iam_role.lambda_execution[0].name : null
}

output "lambda_log_group_name" {
  description = "CloudWatch log group name for Lambda functions"
  value       = var.enable_lambda_baseline ? aws_cloudwatch_log_group.lambda[0].name : null
}

output "ec2_launch_template_id" {
  description = "EC2 launch template ID"
  value       = var.enable_ec2 ? aws_launch_template.main[0].id : null
}

output "ec2_launch_template_arn" {
  description = "EC2 launch template ARN"
  value       = var.enable_ec2 ? aws_launch_template.main[0].arn : null
}

output "ec2_security_group_id" {
  description = "Security group ID attached to EC2 instances"
  value       = var.enable_ec2 ? aws_security_group.ec2[0].id : null
}

output "ec2_asg_name" {
  description = "Auto Scaling Group name"
  value       = var.enable_ec2 && var.enable_asg ? aws_autoscaling_group.main[0].name : null
}
