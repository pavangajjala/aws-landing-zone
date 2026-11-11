output "vpc_id" {
  description = "VPC for this environment."
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnets for workloads."
  value       = module.network.private_subnet_ids
}

output "github_deploy_role_arn" {
  description = "Role for GitHub Actions to assume."
  value       = module.baseline.github_deploy_role_arn
}
