# OpenSearch Module - Outputs

# OpenSearch domain outputs
output "domain_id" {
  description = "ID of the OpenSearch domain"
  value       = var.instance_count > 0 ? aws_opensearch_domain.main[0].domain_id : null
}

output "domain_name" {
  description = "Name of the OpenSearch domain"
  value       = var.instance_count > 0 ? aws_opensearch_domain.main[0].domain_name : null
}

output "domain_arn" {
  description = "ARN of the OpenSearch domain"
  value       = var.instance_count > 0 ? aws_opensearch_domain.main[0].arn : null
}

output "domain_endpoint" {
  description = "Endpoint of the OpenSearch domain"
  value       = var.instance_count > 0 ? aws_opensearch_domain.main[0].endpoint : null
}

output "dashboard_endpoint" {
  description = "Dashboard endpoint of the OpenSearch domain"
  value       = var.instance_count > 0 ? aws_opensearch_domain.main[0].dashboard_endpoint : null
}

output "collection_arn" {
  description = "ARN of the OpenSearch collection for Bedrock"
  value       = var.instance_count > 0 ? aws_opensearch_domain.main[0].arn : null
}

# domain_id output is already defined above

output "master_user_password" {
  description = "Master user password for OpenSearch"
  value       = random_password.opensearch_password.result
  sensitive   = true
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.opensearch.name
}
