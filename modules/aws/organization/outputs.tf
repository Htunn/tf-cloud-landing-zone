output "organizational_units" {
  description = "Map of created organizational units"
  value = {
    for k, v in aws_organizations_organizational_unit.main : k => {
      id   = v.id
      arn  = v.arn
      name = v.name
    }
  }
}

output "service_control_policies" {
  description = "Map of created service control policies"
  value = {
    for k, v in aws_organizations_policy.scp : k => {
      id   = v.id
      arn  = v.arn
      name = v.name
    }
  }
}

output "organizational_unit_ids" {
  description = "List of organizational unit IDs"
  value       = [for ou in aws_organizations_organizational_unit.main : ou.id]
}

output "service_control_policy_ids" {
  description = "List of service control policy IDs"
  value       = [for scp in aws_organizations_policy.scp : scp.id]
}
