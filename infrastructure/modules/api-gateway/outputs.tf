# API Gateway Module - Outputs

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_gateway_arn" {
  description = "ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.main.arn
}

output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.environment}"
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "api_gateway_stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_stage.main.stage_name
}

output "api_gateway_stage_arn" {
  description = "ARN of the API Gateway stage"
  value       = aws_api_gateway_stage.main.arn
}

output "api_gateway_name" {
  description = "Name of the API Gateway"
  value       = aws_api_gateway_rest_api.main.name
}

output "api_gateway_domain" {
  description = "Domain name of the API Gateway"
  value       = "${aws_api_gateway_rest_api.main.id}.execute-api.${data.aws_region.current.name}.amazonaws.com"
}

output "api_gateway_usage_plan_id" {
  description = "ID of the API Gateway usage plan"
  value       = aws_api_gateway_usage_plan.main.id
}

output "api_gateway_api_key_id" {
  description = "ID of the API Gateway API key"
  value       = aws_api_gateway_api_key.main.id
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.api_gateway.name
}

# Data source for current region
data "aws_region" "current" {}
