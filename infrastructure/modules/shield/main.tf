# AWS Shield Module - DDoS Protection for RAG Chatbot

# AWS Shield Advanced Protection
resource "aws_shield_protection" "main" {
  count = var.enable_shield_advanced ? 1 : 0

  name         = "${var.project_name}-${var.environment}-shield-protection"
  resource_arn = var.resource_arn

  tags = var.tags
}

# AWS Shield Advanced Subscription
resource "aws_shield_protection_group" "main" {
  count = var.enable_shield_advanced ? 1 : 0

  protection_group_id = "${var.project_name}-${var.environment}-protection-group"
  aggregation         = "SUM"
  pattern             = "ALL"
  members             = [var.resource_arn]

  depends_on = [aws_shield_protection.main]
}

# AWS Shield Advanced Response Team
resource "aws_shield_protection_health_check_association" "main" {
  count = var.enable_shield_advanced && var.health_check_arn != null ? 1 : 0

  shield_protection_id = aws_shield_protection.main[0].id
  health_check_arn     = var.health_check_arn
}

# CloudWatch Alarms for Shield
resource "aws_cloudwatch_metric_alarm" "ddos_attack" {
  count = var.enable_shield_advanced ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-ddos-attack"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DDoSAttack"
  namespace           = "AWS/DDoSProtection"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors for DDoS attacks"
  alarm_actions       = [aws_sns_topic.shield_alerts[0].arn]

  tags = var.tags
}

# SNS Topic for Shield Alerts
resource "aws_sns_topic" "shield_alerts" {
  count = var.enable_shield_advanced ? 1 : 0

  name = "${var.project_name}-${var.environment}-shield-alerts"

  tags = var.tags
}

# SNS Topic Policy for Shield Alerts
resource "aws_sns_topic_policy" "shield_alerts" {
  count = var.enable_shield_advanced ? 1 : 0

  arn = aws_sns_topic.shield_alerts[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.shield_alerts[0].arn
      }
    ]
  })
}

# AWS Shield Advanced Response Team Contact
resource "aws_shield_protection_health_check_association" "response_team" {
  count = var.enable_shield_advanced && var.response_team_contact_arn != null ? 1 : 0

  shield_protection_id = aws_shield_protection.main[0].id
  health_check_arn     = var.response_team_contact_arn
}
