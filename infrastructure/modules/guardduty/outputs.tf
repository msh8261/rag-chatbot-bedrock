# GuardDuty Module Outputs

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = var.enable_guardduty ? aws_guardduty_detector.main[0].id : null
}

output "guardduty_detector_arn" {
  description = "ARN of the GuardDuty detector"
  value       = var.enable_guardduty ? aws_guardduty_detector.main[0].arn : null
}

output "guardduty_findings_bucket_arn" {
  description = "ARN of the GuardDuty findings S3 bucket"
  value       = var.enable_guardduty ? aws_s3_bucket.guardduty_findings[0].arn : null
}

output "guardduty_alerts_topic_arn" {
  description = "ARN of the GuardDuty alerts SNS topic"
  value       = var.enable_guardduty ? aws_sns_topic.guardduty_alerts[0].arn : null
}
