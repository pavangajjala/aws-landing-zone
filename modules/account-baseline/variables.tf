variable "account_alias" {
  description = "IAM account alias, shown on the sign-in page and in billing. Null to skip."
  type        = string
  default     = null
}

variable "github_repositories" {
  description = "GitHub repositories (owner/name) whose workflows may assume the deploy role through OIDC."
  type        = list(string)
  default     = []
}

variable "github_deploy_branch" {
  description = "Only workflows running on this branch can assume the deploy role."
  type        = string
  default     = "main"
}

variable "deploy_role_policy_arns" {
  description = "Managed policies attached to the GitHub deploy role."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to every resource that supports them."
  type        = map(string)
  default     = {}
}
