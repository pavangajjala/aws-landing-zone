output "github_deploy_role_arn" {
  description = "ARN of the role GitHub Actions assumes, or null when no repositories are configured."
  value       = try(aws_iam_role.github_deploy[0].arn, null)
}
