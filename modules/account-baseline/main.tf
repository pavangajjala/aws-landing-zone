# Settings every account should have before any workload lands in it.

resource "aws_iam_account_alias" "this" {
  count = var.account_alias == null ? 0 : 1

  account_alias = var.account_alias
}

resource "aws_iam_account_password_policy" "this" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  password_reuse_prevention      = 24
  max_password_age               = 90
  allow_users_to_change_password = true
}

resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}

resource "aws_accessanalyzer_analyzer" "this" {
  analyzer_name = "account-analyzer"
  type          = "ACCOUNT"
  tags          = var.tags
}
