# OpenSearch Module - Outputs

# OpenSearch domain outputs commented out (requires AWS subscription)
# output "domain_id" {
#   description = "ID of the OpenSearch domain"
#   value       = aws_opensearch_domain.main.domain_id
# }

# output "domain_name" {
#   description = "Name of the OpenSearch domain"
#   value       = aws_opensearch_domain.main.domain_name
# }

# output "domain_arn" {
#   description = "ARN of the OpenSearch domain"
#   value       = aws_opensearch_domain.main.arn
# }

# output "domain_endpoint" {
#   description = "Endpoint of the OpenSearch domain"
#   value       = aws_opensearch_domain.main.endpoint
# }

# Kibana endpoint is deprecated, using dashboard endpoint instead
# output "dashboard_endpoint" {
#   description = "Dashboard endpoint of the OpenSearch domain"
#   value       = aws_opensearch_domain.main.dashboard_endpoint
# }

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
