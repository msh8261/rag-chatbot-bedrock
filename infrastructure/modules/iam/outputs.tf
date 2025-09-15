# IAM Module - Outputs

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.lambda_role.name
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "ecs_task_role_name" {
  description = "Name of the ECS task role"
  value       = aws_iam_role.ecs_task_role.name
}

output "ecs_execution_role_arn" {
  description = "ARN of the ECS execution role"
  value       = aws_iam_role.ecs_execution_role.arn
}

output "ecs_execution_role_name" {
  description = "Name of the ECS execution role"
  value       = aws_iam_role.ecs_execution_role.name
}

output "bedrock_knowledge_base_role_arn" {
  description = "ARN of the Bedrock knowledge base role"
  value       = aws_iam_role.bedrock_knowledge_base_role.arn
}

output "bedrock_knowledge_base_role_name" {
  description = "Name of the Bedrock knowledge base role"
  value       = aws_iam_role.bedrock_knowledge_base_role.name
}

output "lambda_bedrock_policy_arn" {
  description = "ARN of the Lambda Bedrock policy"
  value       = aws_iam_policy.lambda_bedrock_policy.arn
}

output "ecs_task_policy_arn" {
  description = "ARN of the ECS task policy"
  value       = aws_iam_policy.ecs_task_policy.arn
}

output "bedrock_knowledge_base_policy_arn" {
  description = "ARN of the Bedrock knowledge base policy"
  value       = aws_iam_policy.bedrock_knowledge_base_policy.arn
}

output "bedrock_model_access_policy_arn" {
  description = "ARN of the Bedrock model access policy"
  value       = aws_iam_policy.bedrock_model_access_policy.arn
}
