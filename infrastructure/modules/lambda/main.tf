# Lambda Module - Secure RAG Chatbot Lambda Function

# Lambda Function
resource "aws_lambda_function" "main" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-rag-chatbot"
  role            = var.lambda_role_arn
  handler         = "${var.lambda_function_filename}.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.security_group_id]
  }

  environment {
    variables = {
      DYNAMODB_TABLE_NAME    = var.dynamodb_table_name
      OPENSEARCH_ENDPOINT    = var.opensearch_endpoint
      S3_BUCKET_NAME         = var.s3_bucket_name
      BEDROCK_MODEL_ID       = var.bedrock_model_id
      LOG_LEVEL              = var.log_level
      ENVIRONMENT            = var.environment
    }
  }

  tracing_config {
    mode = var.tracing_mode
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-lambda"
  })

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.lambda_vpc_execution
  ]
}

# Lambda Function URL (for testing)
resource "aws_lambda_function_url" "main" {
  function_name      = aws_lambda_function.main.function_name
  authorization_type = var.authorization_type

  cors {
    allow_credentials = false
    allow_origins     = var.cors_allow_origins
    allow_methods     = var.cors_allow_methods
    allow_headers     = var.cors_allow_headers
    expose_headers    = var.cors_expose_headers
    max_age          = var.cors_max_age
  }
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-rag-chatbot"
  retention_in_days = var.log_retention_days
  # kms_key_id        = var.kms_key_id  # Removed to avoid dependency issues

  tags = var.tags
}

# Dead Letter Queue for Lambda
resource "aws_sqs_queue" "dlq" {
  name = "${var.project_name}-${var.environment}-lambda-dlq"

  kms_master_key_id = var.kms_key_id
  kms_data_key_reuse_period_seconds = 300

  tags = var.tags
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}

# Lambda Permission for CloudWatch Events
resource "aws_lambda_permission" "cloudwatch_events" {
  statement_id  = "AllowExecutionFromCloudWatchEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}

# CloudWatch Event Rule for Lambda Schedule
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "${var.project_name}-${var.environment}-lambda-schedule"
  description         = "Trigger Lambda function on schedule"
  schedule_expression = var.schedule_expression

  tags = var.tags
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "LambdaTarget"
  arn       = aws_lambda_function.main.arn
}

# Lambda Layer for dependencies
resource "aws_lambda_layer_version" "dependencies" {
  filename   = data.archive_file.lambda_layer_zip.output_path
  layer_name = "${var.project_name}-${var.environment}-dependencies"

  compatible_runtimes = var.compatible_runtimes
}

# Archive file for Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"
  source {
    content = file("${path.module}/${var.lambda_function_filename}.py")
    filename = "${var.lambda_function_filename}.py"
  }
}

# Archive file for Lambda layer
data "archive_file" "lambda_layer_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_layer.zip"
  source {
    content = file("${path.module}/requirements.txt")
    filename = "requirements.txt"
  }
}

# IAM Role Policy Attachment for VPC Execution
resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  role       = var.lambda_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
