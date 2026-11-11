variable "name" {
  description = "Name prefix for the VPC and its resources."
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC. A /16 gives each subnet a /20."
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid IPv4 CIDR."
  }
}

variable "az_count" {
  description = "Number of availability zones to spread subnets across."
  type        = number
  default     = 3

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 4
    error_message = "az_count must be between 2 and 4."
  }
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for all private subnets. Cheaper, but an AZ outage takes out egress."
  type        = bool
  default     = false
}

variable "flow_log_retention_days" {
  description = "Retention for VPC flow logs in CloudWatch."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
