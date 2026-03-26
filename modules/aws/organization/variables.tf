variable "organization_id" {
  description = "AWS Organization ID"
  type        = string
}

variable "organization_root_id" {
  description = "Root Organizational Unit ID"
  type        = string
}

variable "organizational_units" {
  description = "Map of organizational units to create"
  type = map(object({
    name      = string
    parent_id = string
  }))
  default = {}
}

variable "service_control_policies" {
  description = "Map of Service Control Policies to create"
  type = map(object({
    name        = string
    description = string
    content     = string
    targets     = list(string)
  }))
  default = {}
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
