variable "organizational_units" {
  description = "Top-level organizational units to create under the root."
  type        = set(string)
  default     = ["security", "infrastructure", "workloads", "sandbox"]
}

variable "accounts" {
  description = "Member accounts keyed by name. `ou` must be one of organizational_units."
  type = map(object({
    email = string
    ou    = string
    tags  = optional(map(string), {})
  }))

  validation {
    condition     = alltrue([for a in values(var.accounts) : can(regex("^[^@\\s]+@[^@\\s]+$", a.email))])
    error_message = "Every account needs a valid, unique root email address."
  }
}

variable "allowed_regions" {
  description = "Regions workloads may use. Requests to other regions are denied by SCP (global services excepted)."
  type        = list(string)
  default     = ["eu-west-1", "ap-south-1"]
}

variable "region_restricted_ous" {
  description = "OUs the region restriction applies to."
  type        = set(string)
  default     = ["workloads", "sandbox"]
}

variable "close_accounts_on_destroy" {
  description = "Close member accounts when they are removed from configuration. Leave false outside of testing."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to every resource that supports them."
  type        = map(string)
  default     = {}
}
