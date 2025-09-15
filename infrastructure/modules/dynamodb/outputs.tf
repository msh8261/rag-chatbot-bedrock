# DynamoDB Module - Outputs

output "chat_history_table_name" {
  description = "Name of the chat history table"
  value       = aws_dynamodb_table.chat_history.name
}

output "chat_history_table_arn" {
  description = "ARN of the chat history table"
  value       = aws_dynamodb_table.chat_history.arn
}

output "user_sessions_table_name" {
  description = "Name of the user sessions table"
  value       = aws_dynamodb_table.user_sessions.name
}

output "user_sessions_table_arn" {
  description = "ARN of the user sessions table"
  value       = aws_dynamodb_table.user_sessions.arn
}

output "app_config_table_name" {
  description = "Name of the app config table"
  value       = aws_dynamodb_table.app_config.name
}

output "app_config_table_arn" {
  description = "ARN of the app config table"
  value       = aws_dynamodb_table.app_config.arn
}
