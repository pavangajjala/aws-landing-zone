variable "permission_sets" {
  description = "Permission sets keyed by name."
  type = map(object({
    description         = string
    session_duration    = optional(string, "PT8H")
    managed_policy_arns = optional(list(string), [])
    inline_policy       = optional(string)
  }))
}

variable "groups" {
  description = "Identity Center groups to create, keyed by display name."
  type        = map(string)
  default     = {}
}

variable "assignments" {
  description = "Which group gets which permission set in which account."
  type = list(object({
    group          = string
    permission_set = string
    account_id     = string
  }))
  default = []

  validation {
    condition     = alltrue([for a in var.assignments : can(regex("^\\d{12}$", a.account_id))])
    error_message = "account_id must be a 12-digit AWS account ID."
  }
}

variable "tags" {
  description = "Tags applied to permission sets."
  type        = map(string)
  default     = {}
}
