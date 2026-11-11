variable "bucket_name" {
  description = "Globally unique name for the state bucket."
  type        = string
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for state locking."
  type        = string
  default     = "terraform-locks"
}

variable "state_writer_arns" {
  description = "IAM principals (CI roles, admin permission sets) allowed to use the state KMS key."
  type        = list(string)
  default     = []
}

variable "noncurrent_version_retention_days" {
  description = "How long old state versions are kept before they expire."
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
