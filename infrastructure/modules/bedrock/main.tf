# Bedrock Module - Secure RAG Chatbot Bedrock Knowledge Base

# Bedrock Knowledge Base
resource "aws_bedrockagent_knowledge_base" "main" {
  name     = "${var.project_name}-${var.environment}-knowledge-base"
  role_arn = var.bedrock_knowledge_base_role_arn

  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v1"
    }
    type = "VECTOR"
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = var.opensearch_collection_arn
      vector_index_name = "bedrock-knowledge-base"
      field_mapping {
        vector_field   = "bedrock-knowledge-base-vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
    }
  }

  tags = var.tags
}

# Bedrock Data Source
resource "aws_bedrockagent_data_source" "main" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.main.id
  name              = "${var.project_name}-${var.environment}-data-source"
  description       = "Data source for RAG chatbot documents"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = var.s3_bucket_arn
      inclusion_filters {
        filter_conditions {
          condition = "PREFIX"
          key       = "documents/"
        }
      }
    }
  }

  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "FIXED_SIZE"
      fixed_size_chunking_configuration {
        max_tokens = 300
        overlap_percentage = 20
      }
    }
  }

  tags = var.tags
}

# Bedrock Guardrails
resource "aws_bedrockguardrails_guardrail" "main" {
  name        = "${var.project_name}-${var.environment}-guardrail"
  description = "Guardrails for RAG chatbot"

  content_policy_config {
    filters_config {
      input_storage_config {
        type = "S3"
        s3_config {
          bucket_arn = var.s3_bucket_arn
          key_prefix = "guardrails/"
        }
      }
    }
  }

  word_policy_config {
    words_config {
      text = "inappropriate, harmful, offensive"
    }
    managed_word_lists_config {
      type = "PROFANITY"
    }
  }

  topic_policy_config {
    topics_config {
      name        = "restricted_topics"
      definition  = "Topics that should be avoided in conversations"
      examples    = ["sensitive information", "personal data"]
    }
  }

  tags = var.tags
}

# Bedrock Model Invocation Logging
resource "aws_bedrock_model_invocation_logging_configuration" "main" {
  logging_config {
    embedding_data_delivery_enabled = true
    image_data_delivery_enabled     = true
    text_data_delivery_enabled      = true

    s3_config {
      bucket_name = var.s3_bucket_name
      key_prefix  = "bedrock-logs/"
    }
  }
}

# Data source for current region
data "aws_region" "current" {}
