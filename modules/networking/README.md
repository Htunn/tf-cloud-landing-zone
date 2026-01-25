# Networking Module

This module creates a production-ready VPC with:

- Multi-AZ public and private subnets
- Internet Gateway for public internet access
- NAT Gateways for private subnet outbound connectivity
- VPC Flow Logs for network traffic monitoring
- Transit Gateway for multi-VPC connectivity (organization mode)
- VPC Endpoints for AWS services (S3, DynamoDB)
- Locked-down default security group

## Features

- **High Availability**: Resources distributed across multiple availability zones
- **Security**: Separate public/private subnets, VPC Flow Logs, secure default security group
- **Cost Optimization**: Option for single NAT Gateway, VPC endpoints to reduce data transfer costs
- **Scalability**: Transit Gateway support for multi-VPC architectures

## Usage

```hcl
module "networking" {
  source = "./modules/networking"

  deployment_mode    = "single-account"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  enable_nat_gateway = true
  single_nat_gateway = false  # Use one NAT GW per AZ for HA
  
  enable_vpc_flow_logs      = true
  flow_logs_log_group_name  = "/aws/vpc/flowlogs/my-vpc"
  
  prefix = "my-company"
  tags   = {
    Environment = "production"
  }
}
```

## Subnet Design

The module automatically calculates subnet CIDR blocks:

- **Public Subnets**: First half of VPC CIDR, one per AZ
- **Private Subnets**: Second half of VPC CIDR, one per AZ

Example with VPC CIDR `10.0.0.0/16` and 3 AZs:
- Public: `10.0.0.0/24`, `10.0.1.0/24`, `10.0.2.0/24`
- Private: `10.0.3.0/24`, `10.0.4.0/24`, `10.0.5.0/24`

## Inputs

See [variables.tf](variables.tf)

## Outputs

See [outputs.tf](outputs.tf)
