# RAG Chatbot Infrastructure - Outputs

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = module.api_gateway.api_gateway_url
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = module.api_gateway.api_gateway_id
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda.function_arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = module.ecs.task_definition_arn
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.distribution_id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for documents"
  value       = module.s3.documents_bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for documents"
  value       = module.s3.documents_bucket_arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for chat history"
  value       = module.dynamodb.chat_history_table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for chat history"
  value       = module.dynamodb.chat_history_table_arn
}

output "opensearch_domain_endpoint" {
  description = "OpenSearch domain endpoint"
  value       = module.opensearch.domain_endpoint
}

output "opensearch_domain_arn" {
  description = "OpenSearch domain ARN"
  value       = module.opensearch.domain_arn
}

output "bedrock_knowledge_base_id" {
  description = "Bedrock knowledge base ID"
  value       = module.bedrock.knowledge_base_id
}

output "bedrock_knowledge_base_arn" {
  description = "Bedrock knowledge base ARN"
  value       = module.bedrock.knowledge_base_arn
}

output "kms_key_id" {
  description = "KMS key ID for encryption"
  value       = module.kms.kms_key_id
}

output "kms_key_arn" {
  description = "KMS key ARN for encryption"
  value       = module.kms.kms_key_arn
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = module.waf.web_acl_arn
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  value       = module.monitoring.log_group_name
}

output "security_hub_findings" {
  description = "Security Hub findings"
  value       = module.monitoring.security_hub_findings
}

output "application_url" {
  description = "URL to access the application"
  value       = var.enable_cloudfront ? "https://${module.cloudfront.domain_name}" : module.api_gateway.api_gateway_url
}

output "monitoring_dashboard_url" {
  description = "URL to the CloudWatch dashboard"
  value       = module.monitoring.dashboard_url
}

output "security_summary" {
  description = "Security implementation summary"
  value = {
    encryption_enabled = var.enable_encryption
    private_subnets = var.enable_private_subnets
    vpc_endpoints = var.enable_vpc_endpoints
    waf_enabled = var.enable_waf
    guardrails_enabled = var.enable_guardrails
    monitoring_enabled = var.enable_monitoring
  }
}
