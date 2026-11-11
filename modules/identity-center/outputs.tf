output "permission_set_arns" {
  description = "Map of permission set name to ARN."
  value       = { for name, ps in aws_ssoadmin_permission_set.this : name => ps.arn }
}

output "group_ids" {
  description = "Map of group display name to Identity Center group ID."
  value       = { for name, group in aws_identitystore_group.this : name => group.group_id }
}
