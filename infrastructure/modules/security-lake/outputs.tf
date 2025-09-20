# Security Lake Module Outputs

output "security_lake_arn" {
  description = "ARN of the Security Lake"
  value       = var.enable_security_lake ? aws_securitylake_data_lake.main[0].arn : null
}

output "security_lake_bucket_arn" {
  description = "ARN of the Security Lake S3 bucket"
  value       = var.enable_security_lake ? aws_s3_bucket.security_lake[0].arn : null
}

output "security_lake_role_arn" {
  description = "ARN of the Security Lake IAM role"
  value       = var.enable_security_lake ? aws_iam_role.security_lake_role[0].arn : null
}

output "custom_log_source_arn" {
  description = "ARN of the custom log source"
  value       = var.enable_security_lake ? aws_securitylake_custom_log_source.main[0].id : null
}

output "subscriber_arn" {
  description = "ARN of the Security Lake subscriber"
  value       = var.enable_security_lake ? aws_securitylake_subscriber.main[0].arn : null
}

output "security_lake_alerts_topic_arn" {
  description = "ARN of the Security Lake alerts SNS topic"
  value       = var.enable_security_lake ? aws_sns_topic.security_lake_alerts[0].arn : null
}
