# ============================================================================
# Organization Module - AWS Organizations, OUs, SCPs
# ============================================================================

# ============================================================================
# Organizational Units
# ============================================================================

resource "aws_organizations_organizational_unit" "main" {
  for_each = var.organizational_units

  name      = each.value.name
  parent_id = each.value.parent_id

  tags = merge(
    var.tags,
    {
      Name = each.value.name
    }
  )
}

# ============================================================================
# Service Control Policies
# ============================================================================

resource "aws_organizations_policy" "scp" {
  for_each = var.service_control_policies

  name        = each.value.name
  description = each.value.description
  type        = "SERVICE_CONTROL_POLICY"
  content     = each.value.content

  tags = merge(
    var.tags,
    {
      Name = each.value.name
    }
  )
}

# ============================================================================
# Service Control Policy Attachments
# ============================================================================

resource "aws_organizations_policy_attachment" "scp" {
  for_each = {
    for attachment in flatten([
      for policy_key, policy in var.service_control_policies : [
        for target in policy.targets : {
          policy_key = policy_key
          target_id  = target
          key        = "${policy_key}-${target}"
        }
      ]
    ]) : attachment.key => attachment
  }

  policy_id = aws_organizations_policy.scp[each.value.policy_key].id
  target_id = each.value.target_id
}
