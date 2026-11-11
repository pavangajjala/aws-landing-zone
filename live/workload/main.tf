locals {
  tags = {
    ManagedBy   = "terraform"
    Repository  = "aws-landing-zone"
    Environment = var.environment
  }
}

module "baseline" {
  source = "../../modules/account-baseline"

  account_alias       = "example-org-${var.environment}"
  github_repositories = var.github_repositories

  # Start narrow. Workload repositories attach what they need to their own
  # roles; this role only needs to read while pipelines are being set up.
  deploy_role_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
}

module "network" {
  source = "../../modules/network"

  name               = var.environment
  cidr_block         = var.vpc_cidr
  single_nat_gateway = var.single_nat_gateway
}
