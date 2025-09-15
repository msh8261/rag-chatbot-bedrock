# Lambda Module - Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  type        = string
}

variable "lambda_role_name" {
  description = "Name of the Lambda execution role"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "opensearch_endpoint" {
  description = "OpenSearch endpoint"
  type        = string
  default     = ""
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "bedrock_model_id" {
  description = "Bedrock model ID"
  type        = string
  default     = "anthropic.claude-3-sonnet-20240229-v1:0"
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
}

variable "timeout" {
  description = "Lambda function timeout"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Lambda function memory size"
  type        = number
  default     = 512
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "api_gateway_execution_arn" {
  description = "API Gateway execution ARN"
  type        = string
  default     = ""
}

variable "lambda_function_filename" {
  description = "Lambda function filename (without .py extension)"
  type        = string
  default     = "lambda_function"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Lambda Configuration
variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}

variable "log_level" {
  description = "Log level for Lambda function"
  type        = string
  default     = "INFO"
}

variable "tracing_mode" {
  description = "X-Ray tracing mode"
  type        = string
  default     = "Active"
}

variable "authorization_type" {
  description = "Lambda function URL authorization type"
  type        = string
  default     = "NONE"
}

variable "cors_allow_origins" {
  description = "CORS allowed origins"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allow_methods" {
  description = "CORS allowed methods"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allow_headers" {
  description = "CORS allowed headers"
  type        = list(string)
  default     = ["date", "keep-alive"]
}

variable "cors_expose_headers" {
  description = "CORS exposed headers"
  type        = list(string)
  default     = ["date", "keep-alive"]
}

variable "cors_max_age" {
  description = "CORS max age"
  type        = number
  default     = 86400
}

variable "schedule_expression" {
  description = "CloudWatch Events schedule expression"
  type        = string
  default     = "rate(5 minutes)"
}

variable "compatible_runtimes" {
  description = "Compatible runtimes for Lambda layer"
  type        = list(string)
  default     = ["python3.11"]
}
