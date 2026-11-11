terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Settings come from backend/<environment>.hcl (see scripts/gen_backend.py).
  backend "s3" {}
}

provider "aws" {
  region = var.region

  # Only this account may be touched. If credentials or the role resolve to a
  # different account, the provider refuses to run.
  allowed_account_ids = [var.account_id]

  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/${var.deployment_role_name}"
    session_name = "terraform-${var.environment}"
  }

  default_tags {
    tags = local.tags
  }
}
