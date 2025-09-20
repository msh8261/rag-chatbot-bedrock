# Amazon Inspector Module Outputs

output "inspector_enabler_id" {
  description = "ID of the Inspector enabler"
  value       = var.enable_inspector ? aws_inspector2_enabler.main[0].id : null
}

output "assessment_target_arn" {
  description = "ARN of the assessment target"
  value       = var.enable_inspector ? aws_inspector_assessment_target.main[0].arn : null
}

output "assessment_template_arn" {
  description = "ARN of the assessment template"
  value       = var.enable_inspector ? aws_inspector_assessment_template.main[0].arn : null
}

# Note: Assessment run output removed as the resource is not supported

output "inspector_alerts_topic_arn" {
  description = "ARN of the Inspector alerts SNS topic"
  value       = var.enable_inspector ? aws_sns_topic.inspector_alerts[0].arn : null
}
