output "account_ids" {
  description = "Account name to ID, used to fill in the workload tfvars."
  value       = module.organization.account_ids
}

output "state_bucket" {
  description = "Bucket holding Terraform state for every environment."
  value       = module.state_backend.bucket_name
}
