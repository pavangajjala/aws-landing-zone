variable "region" {
  description = "Home region for the organization (where Identity Center is enabled)."
  type        = string
  default     = "eu-west-1"
}

variable "org_prefix" {
  description = "Short organization name used in resource names."
  type        = string
  default     = "example-org"
}

variable "email_domain" {
  description = "Domain for account root email addresses (aws+<account>@domain)."
  type        = string
  default     = "example.com"
}
