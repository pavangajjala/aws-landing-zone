data "aws_ssoadmin_instances" "this" {}

locals {
  instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  managed_policy_attachments = merge([
    for name, ps in var.permission_sets : {
      for arn in ps.managed_policy_arns : "${name}|${arn}" => { permission_set = name, policy_arn = arn }
    }
  ]...)

  assignments = {
    for a in var.assignments : "${a.group}|${a.permission_set}|${a.account_id}" => a
  }
}

resource "aws_ssoadmin_permission_set" "this" {
  for_each = var.permission_sets

  name             = each.key
  description      = each.value.description
  instance_arn     = local.instance_arn
  session_duration = each.value.session_duration
  tags             = var.tags
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = local.managed_policy_attachments

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set].arn
  managed_policy_arn = each.value.policy_arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each = { for name, ps in var.permission_sets : name => ps.inline_policy if ps.inline_policy != null }

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  inline_policy      = each.value
}

resource "aws_identitystore_group" "this" {
  for_each = var.groups

  identity_store_id = local.identity_store_id
  display_name      = each.key
  description       = each.value
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = local.assignments

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set].arn

  principal_type = "GROUP"
  principal_id   = aws_identitystore_group.this[each.value.group].group_id

  target_type = "AWS_ACCOUNT"
  target_id   = each.value.account_id
}
