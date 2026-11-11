locals {
  tags = {
    ManagedBy  = "terraform"
    Repository = "aws-landing-zone"
    Scope      = "management"
  }

  accounts = {
    "log-archive"     = "security"
    "security-audit"  = "security"
    "shared-services" = "infrastructure"
    "workload-dev"    = "workloads"
    "workload-prod"   = "workloads"
  }
}

module "organization" {
  source = "../../modules/organization"

  allowed_regions = [var.region, "ap-south-1"]

  accounts = {
    for name, ou in local.accounts : name => {
      email = "aws+${name}@${var.email_domain}"
      ou    = ou
    }
  }
}

module "state_backend" {
  source = "../../modules/state-backend"

  bucket_name = "${var.org_prefix}-terraform-state"
}

module "identity_center" {
  source = "../../modules/identity-center"

  groups = {
    "platform-engineers" = "Own the landing zone and shared infrastructure"
    "developers"         = "Build and run workloads"
    "auditors"           = "Read-only access for security and compliance reviews"
  }

  permission_sets = {
    AdministratorAccess = {
      description         = "Full access. Platform team only, short sessions."
      session_duration    = "PT1H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
    PowerUser = {
      description         = "Build and operate workloads; no IAM or account changes."
      managed_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]
    }
    ReadOnly = {
      description         = "View resources and configuration."
      managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    }
  }

  assignments = concat(
    # Platform engineers administer every account.
    [for name, id in module.organization.account_ids : {
      group = "platform-engineers", permission_set = "AdministratorAccess", account_id = id
    }],
    # Auditors can read everything.
    [for name, id in module.organization.account_ids : {
      group = "auditors", permission_set = "ReadOnly", account_id = id
    }],
    # Developers get power-user access in dev and read-only in prod.
    [
      {
        group          = "developers"
        permission_set = "PowerUser"
        account_id     = module.organization.account_ids["workload-dev"]
      },
      {
        group          = "developers"
        permission_set = "ReadOnly"
        account_id     = module.organization.account_ids["workload-prod"]
      },
    ],
  )
}
