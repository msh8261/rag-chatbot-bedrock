# API Gateway Module - Secure RAG Chatbot API Gateway

# API Gateway
resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-${var.environment}-api"
  description = "RAG Chatbot API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "execute-api:Invoke"
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# API Gateway Resource
resource "aws_api_gateway_resource" "chat" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "chat"
}

# API Gateway Method
resource "aws_api_gateway_method" "chat_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.chat.id
  http_method   = "POST"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.Content-Type" = true
  }
}

# API Gateway Method Response
resource "aws_api_gateway_method_response" "chat_post_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.chat.id
  http_method = aws_api_gateway_method.chat_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# API Gateway Integration
resource "aws_api_gateway_integration" "chat_post" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.chat.id
  http_method = aws_api_gateway_method.chat_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_invoke_arn
}

# API Gateway Integration Response
resource "aws_api_gateway_integration_response" "chat_post_200" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.chat.id
  http_method = aws_api_gateway_method.chat_post.http_method
  status_code = aws_api_gateway_method_response.chat_post_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.chat_post]
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "main" {
  depends_on = [
    aws_api_gateway_method.chat_post,
    aws_api_gateway_integration.chat_post,
    aws_api_gateway_rest_api.main,
  ]

  rest_api_id = aws_api_gateway_rest_api.main.id
  # Don't create stage in deployment - handle separately

  lifecycle {
    create_before_destroy = true
  }

  # Force deployment when policy changes
  triggers = {
    policy = aws_api_gateway_rest_api.main.policy
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.environment

  # access_log_settings {
  #   destination_arn = aws_cloudwatch_log_group.api_gateway.arn
  #   format = jsonencode({
  #     requestId      = "$context.requestId"
  #     ip             = "$context.identity.sourceIp"
  #     caller         = "$context.identity.caller"
  #     user           = "$context.identity.user"
  #     requestTime    = "$context.requestTime"
  #     httpMethod     = "$context.httpMethod"
  #     resourcePath   = "$context.resourcePath"
  #     status         = "$context.status"
  #     protocol       = "$context.protocol"
  #     responseLength = "$context.responseLength"
  #   })
  # }

  lifecycle {
    ignore_changes = [deployment_id]
    create_before_destroy = true
  }

  tags = var.tags
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# API Gateway Usage Plan
resource "aws_api_gateway_usage_plan" "main" {
  name = "${var.project_name}-${var.environment}-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = aws_api_gateway_stage.main.stage_name
  }

  quota_settings {
    limit  = var.rate_limit * 24 * 30  # Monthly limit
    period = "MONTH"
  }

  throttle_settings {
    rate_limit  = var.rate_limit
    burst_limit = var.burst_limit
  }

  tags = var.tags
}

# API Gateway API Key
resource "aws_api_gateway_api_key" "main" {
  name = "${var.project_name}-${var.environment}-api-key"
  description = "API Key for RAG Chatbot"
  
  tags = var.tags
}

# API Gateway Usage Plan Key
resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.main.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main.id
}

# WAF Web ACL Association (if enabled)
resource "aws_wafv2_web_acl_association" "api_gateway" {
  count = var.enable_waf && var.waf_web_acl_arn != "" ? 1 : 0
  
  resource_arn = aws_api_gateway_stage.main.arn
  web_acl_arn  = var.waf_web_acl_arn
}
