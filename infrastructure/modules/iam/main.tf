# IAM Module - Secure RAG Chatbot IAM Roles and Policies

# IAM Role for Lambda Function
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Role for ECS Tasks
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.project_name}-${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Role for Bedrock Knowledge Base
resource "aws_iam_role" "bedrock_knowledge_base_role" {
  name = "${var.project_name}-${var.environment}-bedrock-kb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Lambda Basic Execution Policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda VPC Execution Policy
resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# ECS Task Execution Policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom Lambda Policy for Bedrock Access
resource "aws_iam_policy" "lambda_bedrock_policy" {
  name        = "${var.project_name}-${var.environment}-lambda-bedrock-policy"
  description = "Policy for Lambda to access Bedrock and related services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:GetFoundationModel",
          "bedrock:ListFoundationModels",
          "bedrock:GetModelInvocationLoggingConfiguration",
          "bedrock:PutModelInvocationLoggingConfiguration"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:Retrieve",
          "bedrock:RetrieveAndGenerate"
        ]
        Resource = "arn:aws:bedrock:${data.aws_region.current.name}:${var.account_id}:knowledge-base/*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = "arn:aws:dynamodb:${data.aws_region.current.name}:${var.account_id}:table/${var.project_name}-${var.environment}-*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-${var.environment}-*",
          "arn:aws:s3:::${var.project_name}-${var.environment}-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "es:ESHttpGet",
          "es:ESHttpPost",
          "es:ESHttpPut",
          "es:ESHttpDelete",
          "es:ESHttpHead"
        ]
        Resource = "arn:aws:es:${data.aws_region.current.name}:${var.account_id}:domain/${var.project_name}-${var.environment}-*/*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "arn:aws:kms:${data.aws_region.current.name}:${var.account_id}:key/*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = "arn:aws:sqs:${data.aws_region.current.name}:${var.account_id}:${var.project_name}-${var.environment}-*"
      }
    ]
  })

  tags = var.tags
}

# Attach Lambda Bedrock Policy
resource "aws_iam_role_policy_attachment" "lambda_bedrock_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_bedrock_policy.arn
}

# Custom ECS Task Policy
resource "aws_iam_policy" "ecs_task_policy" {
  name        = "${var.project_name}-${var.environment}-ecs-task-policy"
  description = "Policy for ECS tasks to access required services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${var.account_id}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "arn:aws:ssm:${data.aws_region.current.name}:${var.account_id}:parameter/${var.project_name}/${var.environment}/*"
      }
    ]
  })

  tags = var.tags
}

# Attach ECS Task Policy
resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

# Bedrock Knowledge Base Policy
resource "aws_iam_policy" "bedrock_knowledge_base_policy" {
  name        = "${var.project_name}-${var.environment}-bedrock-kb-policy"
  description = "Policy for Bedrock Knowledge Base to access S3 and OpenSearch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-${var.environment}-documents",
          "arn:aws:s3:::${var.project_name}-${var.environment}-documents/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "aoss:APIAccessAll"
        ]
        Resource = "arn:aws:aoss:${data.aws_region.current.name}:${var.account_id}:collection/*"
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:GetIngestionJob",
          "bedrock:StartIngestionJob",
          "bedrock:ListIngestionJobs"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# Attach Bedrock Knowledge Base Policy
resource "aws_iam_role_policy_attachment" "bedrock_knowledge_base_policy" {
  role       = aws_iam_role.bedrock_knowledge_base_role.name
  policy_arn = aws_iam_policy.bedrock_knowledge_base_policy.arn
}

# Service Control Policy for Bedrock Model Access
resource "aws_iam_policy" "bedrock_model_access_policy" {
  name        = "${var.project_name}-${var.environment}-bedrock-model-access"
  description = "Policy to control access to specific Bedrock models"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/anthropic.claude-3-sonnet-20240229-v1:0",
          "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v1"
        ]
      }
    ]
  })

  tags = var.tags
}

# Attach Bedrock Model Access Policy to Lambda
resource "aws_iam_role_policy_attachment" "lambda_bedrock_model_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.bedrock_model_access_policy.arn
}

# Data source for current region
data "aws_region" "current" {}
