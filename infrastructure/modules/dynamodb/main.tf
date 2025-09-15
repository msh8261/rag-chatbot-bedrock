# DynamoDB Module - Secure RAG Chatbot DynamoDB Tables

# DynamoDB Table for Chat History
resource "aws_dynamodb_table" "chat_history" {
  name           = "${var.project_name}-${var.environment}-chat-history"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "session_id"
  range_key      = "timestamp"

  attribute {
    name = "session_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  global_secondary_index {
    name            = "user-session-index"
    hash_key        = "user_id"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-chat-history"
  })
}

# DynamoDB Table for User Sessions
resource "aws_dynamodb_table" "user_sessions" {
  name           = "${var.project_name}-${var.environment}-user-sessions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "session_id"
    type = "S"
  }

  global_secondary_index {
    name            = "session-index"
    hash_key        = "session_id"
    projection_type = "ALL"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-user-sessions"
  })
}

# DynamoDB Table for Application Configuration
resource "aws_dynamodb_table" "app_config" {
  name           = "${var.project_name}-${var.environment}-app-config"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "config_key"

  attribute {
    name = "config_key"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-app-config"
  })
}
