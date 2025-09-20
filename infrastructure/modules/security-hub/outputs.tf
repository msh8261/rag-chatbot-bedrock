# Security Hub Module Outputs

output "security_hub_arn" {
  description = "ARN of the Security Hub"
  value       = var.enable_security_hub ? aws_securityhub_account.main[0].arn : null
}

output "security_hub_id" {
  description = "ID of the Security Hub"
  value       = var.enable_security_hub ? aws_securityhub_account.main[0].id : null
}

output "security_hub_action_target_arn" {
  description = "ARN of the Security Hub action target"
  value       = var.enable_security_hub ? aws_securityhub_action_target.main[0].arn : null
}

output "security_hub_insights" {
  description = "Security Hub insights"
  value = var.enable_security_hub ? {
    high_severity_findings = aws_securityhub_insight.high_severity_findings[0].arn
    lambda_findings        = aws_securityhub_insight.lambda_findings[0].arn
    ecs_findings          = aws_securityhub_insight.ecs_findings[0].arn
  } : null
}

output "security_hub_alerts_topic_arn" {
  description = "ARN of the Security Hub alerts SNS topic"
  value       = var.enable_security_hub ? aws_sns_topic.security_hub_alerts[0].arn : null
}
