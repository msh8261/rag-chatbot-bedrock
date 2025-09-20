# Security Lake Module - Centralized Log Analysis for RAG Chatbot

# Security Lake Data Lake
resource "aws_securitylake_data_lake" "main" {
  count = var.enable_security_lake ? 1 : 0

  meta_store_manager_role_arn = aws_iam_role.security_lake_role[0].arn

  configuration {
    region = data.aws_region.current.name
  }

  tags = var.tags
}

# IAM Role for Security Lake
resource "aws_iam_role" "security_lake_role" {
  count = var.enable_security_lake ? 1 : 0

  name = "${var.project_name}-${var.environment}-security-lake-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "securitylake.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for Security Lake
resource "aws_iam_policy" "security_lake_policy" {
  count = var.enable_security_lake ? 1 : 0

  name        = "${var.project_name}-${var.environment}-security-lake-policy"
  description = "Policy for Security Lake to access required services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.security_lake[0].arn,
          "${aws_s3_bucket.security_lake[0].arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = var.kms_key_id
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${var.account_id}:*"
      }
    ]
  })

  tags = var.tags
}

# Attach Security Lake Policy
resource "aws_iam_role_policy_attachment" "security_lake_policy" {
  count = var.enable_security_lake ? 1 : 0

  role       = aws_iam_role.security_lake_role[0].name
  policy_arn = aws_iam_policy.security_lake_policy[0].arn
}

# S3 Bucket for Security Lake
resource "aws_s3_bucket" "security_lake" {
  count = var.enable_security_lake ? 1 : 0

  bucket = "${var.project_name}-${var.environment}-security-lake"

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "security_lake" {
  count = var.enable_security_lake ? 1 : 0

  bucket = aws_s3_bucket.security_lake[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "security_lake" {
  count = var.enable_security_lake ? 1 : 0

  bucket = aws_s3_bucket.security_lake[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_id
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "security_lake" {
  count = var.enable_security_lake ? 1 : 0

  bucket = aws_s3_bucket.security_lake[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Security Lake Custom Log Source
resource "aws_securitylake_custom_log_source" "main" {
  count = var.enable_security_lake ? 1 : 0

  source_name    = "${var.project_name}-${var.environment}-custom-logs"
  source_version = "1.0"

  configuration {
    crawler_configuration {
      role_arn = aws_iam_role.security_lake_role[0].arn
    }
    provider_identity {
      external_id = "security-lake-external-id"
      principal   = data.aws_caller_identity.current.account_id
    }
  }

  depends_on = [aws_securitylake_data_lake.main]
}

# Security Lake Subscriber
resource "aws_securitylake_subscriber" "main" {
  count = var.enable_security_lake ? 1 : 0

  subscriber_name = "${var.project_name}-${var.environment}-subscriber"
  subscriber_description = "Security Lake subscriber for RAG chatbot"

  source {
    aws_log_source_resource {
      source_name    = "ROUTE53"
      source_version = "1.0"
    }
  }

  subscriber_identity {
    external_id = "security-lake-subscriber-external-id"
    principal   = data.aws_caller_identity.current.account_id
  }

  depends_on = [aws_securitylake_data_lake.main]
}

# CloudWatch Alarms for Security Lake
resource "aws_cloudwatch_metric_alarm" "security_lake_events" {
  count = var.enable_security_lake ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-security-lake-events"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EventsProcessed"
  namespace           = "AWS/SecurityLake"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1000"
  alarm_description   = "This metric monitors Security Lake events processed"
  alarm_actions       = [aws_sns_topic.security_lake_alerts[0].arn]

  tags = var.tags
}

# SNS Topic for Security Lake Alerts
resource "aws_sns_topic" "security_lake_alerts" {
  count = var.enable_security_lake ? 1 : 0

  name = "${var.project_name}-${var.environment}-security-lake-alerts"

  tags = var.tags
}

# SNS Topic Policy for Security Lake Alerts
resource "aws_sns_topic_policy" "security_lake_alerts" {
  count = var.enable_security_lake ? 1 : 0

  arn = aws_sns_topic.security_lake_alerts[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "securitylake.amazonaws.com"
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.security_lake_alerts[0].arn
      }
    ]
  })
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
