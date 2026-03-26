variable "enable_ecs" {
  description = "Enable ECS cluster with Fargate and Fargate Spot capacity providers"
  type        = bool
  default     = true
}

variable "ecs_cluster_name" {
  description = "Name for the ECS cluster. Defaults to <prefix>-cluster when null."
  type        = string
  default     = null
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for the ECS cluster"
  type        = bool
  default     = true
}

variable "enable_lambda_baseline" {
  description = "Create a shared Lambda IAM execution role and CloudWatch log group"
  type        = bool
  default     = true
}

variable "lambda_log_retention_days" {
  description = "CloudWatch Logs retention period for Lambda logs in days"
  type        = number
  default     = 30
}

variable "enable_ec2" {
  description = "Enable EC2 launch template (and optional Auto Scaling Group)"
  type        = bool
  default     = false
}

variable "enable_asg" {
  description = "Enable Auto Scaling Group for EC2 instances. Requires enable_ec2 = true."
  type        = bool
  default     = false
}

variable "ec2_instance_type" {
  description = "EC2 instance type used in the launch template"
  type        = string
  default     = "t3.micro"
}

variable "ec2_ami_id" {
  description = "AMI ID for the EC2 launch template. Required when enable_ec2 = true."
  type        = string
  default     = null
}

variable "ec2_min_size" {
  description = "Minimum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "ec2_max_size" {
  description = "Maximum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 10
}

variable "ec2_desired_capacity" {
  description = "Desired number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "vpc_id" {
  description = "VPC ID for compute resources (required when enable_ec2 = true)"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs for Auto Scaling Group placement"
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "KMS key ARN for EBS volume and CloudWatch log encryption"
  type        = string
  default     = null
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default     = {}
}
