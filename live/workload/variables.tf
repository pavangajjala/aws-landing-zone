variable "environment" {
  description = "Environment name. Must match the backend config that was used for init."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "account_id" {
  description = "ID of the member account this environment deploys into."
  type        = string

  validation {
    condition     = can(regex("^\\d{12}$", var.account_id))
    error_message = "account_id must be a 12-digit AWS account ID."
  }
}

variable "region" {
  description = "Region for regional resources."
  type        = string
  default     = "eu-west-1"
}

variable "deployment_role_name" {
  description = "Role in the member account that Terraform assumes."
  type        = string
  default     = "OrganizationAccountAccessRole"
}

variable "vpc_cidr" {
  description = "CIDR block for the environment's VPC. Must not overlap with other environments."
  type        = string
}

variable "single_nat_gateway" {
  description = "One NAT gateway instead of one per AZ."
  type        = bool
  default     = false
}

variable "github_repositories" {
  description = "Repositories whose main branch may deploy to this account."
  type        = list(string)
  default     = []
}
