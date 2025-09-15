# RAG Chatbot Infrastructure - Main Configuration
# This implements the secure architecture blueprint from AWS Security Blog

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Security    = "High"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

# Local values
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
  # VPC CIDR blocks
  vpc_cidr = "10.0.0.0/16"
  
  # Subnet CIDR blocks
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  database_subnet_cidrs = ["10.0.30.0/24", "10.0.40.0/24"]
  
  # Availability zones
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

# VPC Module
module "vpc" {
  source = "../modules/vpc"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = local.vpc_cidr
  azs          = local.azs
  public_subnet_cidrs  = local.public_subnet_cidrs
  private_subnet_cidrs = local.private_subnet_cidrs
  database_subnet_cidrs = local.database_subnet_cidrs
  
  tags = local.common_tags
}

# Security Groups Module
module "security_groups" {
  source = "../modules/security-groups"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  
  tags = local.common_tags
}

# IAM Module
module "iam" {
  source = "../modules/iam"
  
  project_name = var.project_name
  environment  = var.environment
  account_id   = data.aws_caller_identity.current.account_id
  
  tags = local.common_tags
}

# S3 Module
module "s3" {
  source = "../modules/s3"
  
  project_name = var.project_name
  environment  = var.environment
  kms_key_id   = module.kms.kms_key_id
  
  tags = local.common_tags
}

# KMS Module
module "kms" {
  source = "../modules/kms"
  
  project_name = var.project_name
  environment  = var.environment
  
  tags = local.common_tags
}

# DynamoDB Module
module "dynamodb" {
  source = "../modules/dynamodb"
  
  project_name = var.project_name
  environment  = var.environment
  kms_key_id   = module.kms.kms_key_id
  
  tags = local.common_tags
}

# OpenSearch Module
module "opensearch" {
  source = "../modules/opensearch"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security_groups.opensearch_security_group_id
  kms_key_id   = module.kms.kms_key_id
  
  tags = local.common_tags
}

# Lambda Module
module "lambda" {
  source = "../modules/lambda"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security_groups.lambda_security_group_id
  dynamodb_table_name = module.dynamodb.chat_history_table_name
  opensearch_endpoint = module.opensearch.domain_endpoint
  s3_bucket_name = module.s3.documents_bucket_name
  kms_key_id   = module.kms.kms_key_id
  
  tags = local.common_tags
}

# API Gateway Module
module "api_gateway" {
  source = "../modules/api-gateway"
  
  project_name = var.project_name
  environment  = var.environment
  lambda_function_name = module.lambda.function_name
  lambda_invoke_arn    = module.lambda.invoke_arn
  
  tags = local.common_tags
}

# ECS Module
module "ecs" {
  source = "../modules/ecs"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security_groups.ecs_security_group_id
  api_gateway_url = module.api_gateway.api_gateway_url
  
  tags = local.common_tags
}

# CloudFront Module
module "cloudfront" {
  source = "../modules/cloudfront"
  
  project_name = var.project_name
  environment  = var.environment
  api_gateway_url = module.api_gateway.api_gateway_url
  
  tags = local.common_tags
}

# WAF Module
module "waf" {
  source = "../modules/waf"
  
  project_name = var.project_name
  environment  = var.environment
  
  tags = local.common_tags
}

# Monitoring Module
module "monitoring" {
  source = "../modules/monitoring"
  
  project_name = var.project_name
  environment  = var.environment
  lambda_function_name = module.lambda.function_name
  api_gateway_id = module.api_gateway.api_gateway_id
  
  tags = local.common_tags
}

# Bedrock Module
module "bedrock" {
  source = "../modules/bedrock"
  
  project_name = var.project_name
  environment  = var.environment
  opensearch_domain_arn = module.opensearch.domain_arn
  s3_bucket_arn = module.s3.documents_bucket_arn
  
  tags = local.common_tags
}
