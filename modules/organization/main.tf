resource "aws_organizations_organization" "this" {
  feature_set = "ALL"

  enabled_policy_types = ["SERVICE_CONTROL_POLICY", "TAG_POLICY"]

  aws_service_access_principals = [
    "sso.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com",
    "access-analyzer.amazonaws.com",
  ]
}

resource "aws_organizations_organizational_unit" "this" {
  for_each = var.organizational_units

  name      = each.value
  parent_id = aws_organizations_organization.this.roots[0].id
  tags      = var.tags
}

resource "aws_organizations_account" "this" {
  for_each = var.accounts

  name      = each.key
  email     = each.value.email
  parent_id = aws_organizations_organizational_unit.this[each.value.ou].id

  # Billing access for IAM users is decided once at creation and cannot be
  # changed later through the API, so it is ignored after the first apply.
  iam_user_access_to_billing = "DENY"
  close_on_deletion          = var.close_accounts_on_destroy

  tags = merge(var.tags, each.value.tags)

  lifecycle {
    ignore_changes  = [iam_user_access_to_billing, role_name]
    prevent_destroy = true
  }
}
