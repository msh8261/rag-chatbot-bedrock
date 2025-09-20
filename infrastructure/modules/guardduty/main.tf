# GuardDuty Module - Threat Detection for RAG Chatbot

# GuardDuty Detector
resource "aws_guardduty_detector" "main" {
  count = var.enable_guardduty ? 1 : 0

  enable = true

  datasources {
    s3_logs {
      enable = var.enable_s3_protection
    }
    kubernetes {
      audit_logs {
        enable = var.enable_kubernetes_protection
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.enable_malware_protection
        }
      }
    }
  }

  tags = var.tags
}

# GuardDuty Findings Bucket
resource "aws_s3_bucket" "guardduty_findings" {
  count = var.enable_guardduty ? 1 : 0

  bucket = "${var.project_name}-${var.environment}-guardduty-findings"

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "guardduty_findings" {
  count = var.enable_guardduty ? 1 : 0

  bucket = aws_s3_bucket.guardduty_findings[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "guardduty_findings" {
  count = var.enable_guardduty ? 1 : 0

  bucket = aws_s3_bucket.guardduty_findings[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_id
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "guardduty_findings" {
  count = var.enable_guardduty ? 1 : 0

  bucket = aws_s3_bucket.guardduty_findings[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# GuardDuty Publishing Destination
resource "aws_guardduty_publishing_destination" "main" {
  count = var.enable_guardduty ? 1 : 0

  detector_id     = aws_guardduty_detector.main[0].id
  destination_arn = aws_s3_bucket.guardduty_findings[0].arn
  kms_key_arn     = var.kms_key_id

  depends_on = [aws_s3_bucket_policy.guardduty_findings]
}

# S3 Bucket Policy for GuardDuty
resource "aws_s3_bucket_policy" "guardduty_findings" {
  count = var.enable_guardduty ? 1 : 0

  bucket = aws_s3_bucket.guardduty_findings[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Allow GuardDuty to write findings"
        Effect = "Allow"
        Principal = {
          Service = "guardduty.amazonaws.com"
        }
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.guardduty_findings[0].arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid    = "Allow GuardDuty to get bucket ACL"
        Effect = "Allow"
        Principal = {
          Service = "guardduty.amazonaws.com"
        }
        Action = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.guardduty_findings[0].arn
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# GuardDuty Threat Intel Set
resource "aws_guardduty_threatintelset" "main" {
  count = var.enable_guardduty ? 1 : 0

  detector_id = aws_guardduty_detector.main[0].id
  name        = "${var.project_name}-${var.environment}-threat-intel-set"
  format      = "TXT"
  location    = "https://s3.amazonaws.com/guardduty-threat-intel-set/ThreatIntelSet.txt"
  activate    = true

  tags = var.tags
}

# GuardDuty IP Set
resource "aws_guardduty_ipset" "main" {
  count = var.enable_guardduty ? 1 : 0

  detector_id = aws_guardduty_detector.main[0].id
  name        = "${var.project_name}-${var.environment}-ip-set"
  format      = "TXT"
  location    = "https://s3.amazonaws.com/guardduty-ip-set/TrustedIPs.txt"
  activate    = true

  tags = var.tags
}

# CloudWatch Alarms for GuardDuty
resource "aws_cloudwatch_metric_alarm" "guardduty_findings" {
  count = var.enable_guardduty ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-guardduty-findings"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "TotalFindings"
  namespace           = "AWS/GuardDuty"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors for GuardDuty findings"
  alarm_actions       = [aws_sns_topic.guardduty_alerts[0].arn]

  tags = var.tags
}

# SNS Topic for GuardDuty Alerts
resource "aws_sns_topic" "guardduty_alerts" {
  count = var.enable_guardduty ? 1 : 0

  name = "${var.project_name}-${var.environment}-guardduty-alerts"

  tags = var.tags
}

# SNS Topic Policy for GuardDuty Alerts
resource "aws_sns_topic_policy" "guardduty_alerts" {
  count = var.enable_guardduty ? 1 : 0

  arn = aws_sns_topic.guardduty_alerts[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "guardduty.amazonaws.com"
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.guardduty_alerts[0].arn
      }
    ]
  })
}
