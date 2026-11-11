output "organization_id" {
  description = "ID of the AWS Organization."
  value       = aws_organizations_organization.this.id
}

output "account_ids" {
  description = "Map of account name to account ID."
  value       = { for name, account in aws_organizations_account.this : name => account.id }
}

output "organizational_unit_ids" {
  description = "Map of OU name to OU ID."
  value       = { for name, ou in aws_organizations_organizational_unit.this : name => ou.id }
}
