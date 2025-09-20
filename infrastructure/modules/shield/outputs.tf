# AWS Shield Module Outputs

output "shield_protection_id" {
  description = "ID of the Shield protection"
  value       = var.enable_shield_advanced ? aws_shield_protection.main[0].id : null
}

output "shield_protection_arn" {
  description = "ARN of the Shield protection"
  value       = var.enable_shield_advanced ? aws_shield_protection.main[0].arn : null
}

output "shield_protection_group_id" {
  description = "ID of the Shield protection group"
  value       = var.enable_shield_advanced ? aws_shield_protection_group.main[0].id : null
}

output "shield_alerts_topic_arn" {
  description = "ARN of the Shield alerts SNS topic"
  value       = var.enable_shield_advanced ? aws_sns_topic.shield_alerts[0].arn : null
}
