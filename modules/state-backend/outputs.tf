output "bucket_name" {
  description = "Name of the state bucket."
  value       = aws_s3_bucket.state.id
}

output "kms_key_arn" {
  description = "ARN of the KMS key that encrypts state."
  value       = aws_kms_key.state.arn
}
