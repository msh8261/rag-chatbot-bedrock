# KMS Module - Outputs

output "kms_key_id" {
  description = "ID of the main KMS key"
  value       = aws_kms_key.main.key_id
}

output "kms_key_arn" {
  description = "ARN of the main KMS key"
  value       = aws_kms_key.main.arn
}

output "kms_key_alias" {
  description = "Alias of the main KMS key"
  value       = aws_kms_alias.main.name
}

output "s3_kms_key_id" {
  description = "ID of the S3 KMS key"
  value       = aws_kms_key.s3.key_id
}

output "s3_kms_key_arn" {
  description = "ARN of the S3 KMS key"
  value       = aws_kms_key.s3.arn
}

output "s3_kms_key_alias" {
  description = "Alias of the S3 KMS key"
  value       = aws_kms_alias.s3.name
}
