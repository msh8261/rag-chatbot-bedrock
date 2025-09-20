# Bedrock Module - Outputs

output "knowledge_base_id" {
  description = "ID of the Bedrock knowledge base"
  value       = aws_bedrockagent_knowledge_base.main.id
}

output "knowledge_base_arn" {
  description = "ARN of the Bedrock knowledge base"
  value       = aws_bedrockagent_knowledge_base.main.arn
}

output "data_source_id" {
  description = "ID of the Bedrock data source"
  value       = aws_bedrockagent_data_source.main.id
}

output "data_source_arn" {
  description = "ARN of the Bedrock data source"
  value       = aws_bedrockagent_data_source.main.id
}
