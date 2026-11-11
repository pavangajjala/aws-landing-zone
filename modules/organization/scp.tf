# Guardrails that apply regardless of what IAM in a member account allows.

data "aws_iam_policy_document" "protect_guardrails" {
  statement {
    sid       = "DenyLeavingOrganization"
    effect    = "Deny"
    actions   = ["organizations:LeaveOrganization"]
    resources = ["*"]
  }

  statement {
    sid    = "DenyDisablingAuditServices"
    effect = "Deny"
    actions = [
      "cloudtrail:StopLogging",
      "cloudtrail:DeleteTrail",
      "config:StopConfigurationRecorder",
      "config:DeleteConfigurationRecorder",
      "guardduty:DeleteDetector",
      "guardduty:DisassociateFromMasterAccount",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "DenyRootUser"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:root"]
    }
  }
}

data "aws_iam_policy_document" "region_restriction" {
  statement {
    sid    = "DenyOutsideAllowedRegions"
    effect = "Deny"

    # Global services are served from us-east-1 and must stay reachable.
    not_actions = [
      "iam:*",
      "organizations:*",
      "sts:*",
      "route53:*",
      "route53domains:*",
      "cloudfront:*",
      "waf:*",
      "wafv2:*",
      "shield:*",
      "support:*",
      "budgets:*",
      "ce:*",
      "health:*",
      "sso:*",
      "kms:*",
      "acm:*",
    ]
    resources = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = var.allowed_regions
    }
  }
}

resource "aws_organizations_policy" "protect_guardrails" {
  name        = "protect-guardrails"
  description = "Stops member accounts leaving the organization, disabling audit services or using the root user."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.protect_guardrails.json
  tags        = var.tags
}

resource "aws_organizations_policy" "region_restriction" {
  name        = "region-restriction"
  description = "Denies regional API calls outside ${join(", ", var.allowed_regions)}."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.region_restriction.json
  tags        = var.tags
}

resource "aws_organizations_policy_attachment" "protect_guardrails" {
  for_each = aws_organizations_organizational_unit.this

  policy_id = aws_organizations_policy.protect_guardrails.id
  target_id = each.value.id
}

resource "aws_organizations_policy_attachment" "region_restriction" {
  for_each = var.region_restricted_ous

  policy_id = aws_organizations_policy.region_restriction.id
  target_id = aws_organizations_organizational_unit.this[each.value].id
}
