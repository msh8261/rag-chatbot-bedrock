# Amazon Inspector Module - Vulnerability Assessment for RAG Chatbot

# Inspector V2 Enabler
resource "aws_inspector2_enabler" "main" {
  count = var.enable_inspector ? 1 : 0

  account_ids   = [var.account_id]
  resource_types = var.resource_types

  depends_on = [aws_inspector2_organization_configuration.main]
}

# Inspector V2 Organization Configuration
resource "aws_inspector2_organization_configuration" "main" {
  count = var.enable_inspector ? 1 : 0

  auto_enable {
    ec2       = var.enable_ec2_scanning
    ecr       = var.enable_ecr_scanning
    lambda    = var.enable_lambda_scanning
    lambda_code = var.enable_lambda_scanning
  }
}

# Inspector V2 Assessment Target
resource "aws_inspector_assessment_target" "main" {
  count = var.enable_inspector ? 1 : 0

  name = "${var.project_name}-${var.environment}-assessment-target"
}

# Inspector V2 Assessment Template
resource "aws_inspector_assessment_template" "main" {
  count = var.enable_inspector ? 1 : 0

  name       = "${var.project_name}-${var.environment}-assessment-template"
  target_arn = aws_inspector_assessment_target.main[0].arn

  duration = var.assessment_duration

  rules_package_arns = var.rules_package_arns
}

# Note: Inspector assessment runs are not supported in the AWS provider
# Assessment runs need to be triggered manually or via other means

# CloudWatch Alarms for Inspector
resource "aws_cloudwatch_metric_alarm" "inspector_critical_findings" {
  count = var.enable_inspector ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-inspector-critical-findings"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CriticalFindings"
  namespace           = "AWS/Inspector2"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors for critical Inspector findings"
  alarm_actions       = [aws_sns_topic.inspector_alerts[0].arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "inspector_high_findings" {
  count = var.enable_inspector ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-inspector-high-findings"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HighFindings"
  namespace           = "AWS/Inspector2"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors for high severity Inspector findings"
  alarm_actions       = [aws_sns_topic.inspector_alerts[0].arn]

  tags = var.tags
}

# SNS Topic for Inspector Alerts
resource "aws_sns_topic" "inspector_alerts" {
  count = var.enable_inspector ? 1 : 0

  name = "${var.project_name}-${var.environment}-inspector-alerts"

  tags = var.tags
}

# SNS Topic Policy for Inspector Alerts
resource "aws_sns_topic_policy" "inspector_alerts" {
  count = var.enable_inspector ? 1 : 0

  arn = aws_sns_topic.inspector_alerts[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "inspector2.amazonaws.com"
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.inspector_alerts[0].arn
      }
    ]
  })
}

# Inspector V2 Filter for Lambda Functions
resource "aws_inspector2_filter" "lambda_functions" {
  count = var.enable_inspector ? 1 : 0

  name        = "${var.project_name}-${var.environment}-lambda-filter"
  description = "Filter for Lambda functions in the RAG chatbot"
  filter_criteria {
    resource_type {
      comparison = "EQUALS"
      value      = "AWS_LAMBDA_FUNCTION"
    }
    resource_tags {
      comparison = "EQUALS"
      key        = "Project"
      value      = var.project_name
    }
  }

  action = "NONE"

  tags = var.tags
}

# Inspector V2 Filter for ECS Tasks
resource "aws_inspector2_filter" "ecs_tasks" {
  count = var.enable_inspector ? 1 : 0

  name        = "${var.project_name}-${var.environment}-ecs-filter"
  description = "Filter for ECS tasks in the RAG chatbot"
  filter_criteria {
    resource_type {
      comparison = "EQUALS"
      value      = "AWS_ECS_TASK"
    }
    resource_tags {
      comparison = "EQUALS"
      key        = "Project"
      value      = var.project_name
    }
  }

  action = "NONE"

  tags = var.tags
}
