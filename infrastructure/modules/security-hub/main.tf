# Security Hub Module - Centralized Security Management for RAG Chatbot

# Security Hub Account
resource "aws_securityhub_account" "main" {
  count = var.enable_security_hub ? 1 : 0

  enable_default_standards = var.enable_default_standards
}

# Security Hub Standards Subscriptions
resource "aws_securityhub_standards_subscription" "cis" {
  count = var.enable_security_hub && var.enable_cis_standard ? 1 : 0

  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standard/cis-aws-foundations-benchmark/v/1.2.0"
}

resource "aws_securityhub_standards_subscription" "pci" {
  count = var.enable_security_hub && var.enable_pci_standard ? 1 : 0

  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standard/pci-dss/v/3.2.1"
}

resource "aws_securityhub_standards_subscription" "nist" {
  count = var.enable_security_hub && var.enable_nist_standard ? 1 : 0

  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standard/nist-cybersecurity-framework/v/1.0.0"
}

# Security Hub Custom Action
resource "aws_securityhub_action_target" "main" {
  count = var.enable_security_hub ? 1 : 0

  depends_on    = [aws_securityhub_account.main]
  name          = "${var.project_name}-${var.environment}-security-action"
  description   = "Custom action for RAG chatbot security findings"
  identifier    = "RAGChatbotSec"
}

# Security Hub Insight
resource "aws_securityhub_insight" "high_severity_findings" {
  count = var.enable_security_hub ? 1 : 0

  depends_on = [aws_securityhub_account.main]
  name       = "${var.project_name}-${var.environment}-high-severity-findings"
  group_by_attribute = "SeverityLabel"

  filters {
    severity_label {
      comparison = "EQUALS"
      value      = "HIGH"
    }
    severity_label {
      comparison = "EQUALS"
      value      = "CRITICAL"
    }
  }
}

# Security Hub Insight for Lambda Functions
resource "aws_securityhub_insight" "lambda_findings" {
  count = var.enable_security_hub ? 1 : 0

  depends_on = [aws_securityhub_account.main]
  name       = "${var.project_name}-${var.environment}-lambda-findings"
  group_by_attribute = "ResourceType"

  filters {
    resource_type {
      comparison = "EQUALS"
      value      = "AwsLambdaFunction"
    }
  }
}

# Security Hub Insight for ECS Tasks
resource "aws_securityhub_insight" "ecs_findings" {
  count = var.enable_security_hub ? 1 : 0

  depends_on = [aws_securityhub_account.main]
  name       = "${var.project_name}-${var.environment}-ecs-findings"
  group_by_attribute = "ResourceType"

  filters {
    resource_type {
      comparison = "EQUALS"
      value      = "AwsEcsTask"
    }
  }
}

# Security Hub Finding Aggregator
resource "aws_securityhub_finding_aggregator" "main" {
  count = var.enable_security_hub && var.enable_finding_aggregation ? 1 : 0

  depends_on = [aws_securityhub_account.main]
  linking_mode = "ALL_REGIONS"
}

# CloudWatch Alarms for Security Hub
resource "aws_cloudwatch_metric_alarm" "security_hub_critical_findings" {
  count = var.enable_security_hub ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-security-hub-critical-findings"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CriticalFindings"
  namespace           = "AWS/SecurityHub"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors for critical Security Hub findings"
  alarm_actions       = [aws_sns_topic.security_hub_alerts[0].arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "security_hub_high_findings" {
  count = var.enable_security_hub ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-security-hub-high-findings"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HighFindings"
  namespace           = "AWS/SecurityHub"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors for high severity Security Hub findings"
  alarm_actions       = [aws_sns_topic.security_hub_alerts[0].arn]

  tags = var.tags
}

# SNS Topic for Security Hub Alerts
resource "aws_sns_topic" "security_hub_alerts" {
  count = var.enable_security_hub ? 1 : 0

  name = "${var.project_name}-${var.environment}-security-hub-alerts"

  tags = var.tags
}

# SNS Topic Policy for Security Hub Alerts
resource "aws_sns_topic_policy" "security_hub_alerts" {
  count = var.enable_security_hub ? 1 : 0

  arn = aws_sns_topic.security_hub_alerts[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "securityhub.amazonaws.com"
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.security_hub_alerts[0].arn
      }
    ]
  })
}

# Data source for current region
data "aws_region" "current" {}
