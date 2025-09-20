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
      ManagedBy   = var.managed_by
      Security    = var.security_level
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = var.availability_zones_state
}

# Local values
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = var.managed_by
  }
  
  # Availability zones
  azs = slice(data.aws_availability_zones.available.names, 0, var.availability_zones_count)
}

# VPC Module
module "vpc" {
  source = "../modules/vpc"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  azs          = local.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  
  # VPC Configuration
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  enable_nat_gateway   = var.enable_nat_gateway
  enable_vpc_endpoints = var.enable_vpc_endpoints
  
  # Route Configuration
  public_route_cidr  = var.public_route_cidr
  private_route_cidr = var.private_route_cidr
  
  # Security group IDs for VPC endpoints
  bedrock_security_group_id = module.security_groups.vpc_endpoints_security_group_id
  lambda_security_group_id = module.security_groups.vpc_endpoints_security_group_id
  opensearch_security_group_id = module.security_groups.opensearch_security_group_id
  
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
  instance_type = var.opensearch_instance_type
  instance_count = var.opensearch_instance_count
  log_retention_days = var.log_retention_days
  
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
  lambda_role_arn = module.iam.lambda_role_arn
  lambda_role_name = module.iam.lambda_role_name
  dynamodb_table_name = module.dynamodb.chat_history_table_name
  opensearch_endpoint = module.opensearch.domain_endpoint
  s3_bucket_name = module.s3.documents_bucket_name
  kms_key_id   = module.kms.kms_key_id
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn
  memory_size  = var.lambda_memory_size
  timeout      = var.lambda_timeout
  bedrock_model_id = var.bedrock_model_id
  lambda_function_filename = var.lambda_function_filename
  
  # Lambda Configuration
  runtime = "python3.11"
  log_level = "INFO"
  tracing_mode = "Active"
  authorization_type = "NONE"
  cors_allow_origins = ["*"]
  cors_allow_methods = ["*"]
  cors_allow_headers = ["date", "keep-alive"]
  cors_expose_headers = ["date", "keep-alive"]
  cors_max_age = 86400
  schedule_expression = "rate(5 minutes)"
  compatible_runtimes = ["python3.11"]
  
  tags = local.common_tags
}

# API Gateway Module
module "api_gateway" {
  source = "../modules/api-gateway"
  
  project_name = var.project_name
  environment  = var.environment
  lambda_function_name = module.lambda.function_name
  lambda_invoke_arn    = module.lambda.invoke_arn
  kms_key_id   = module.kms.kms_key_id
  rate_limit   = var.rate_limit
  burst_limit  = var.burst_limit
  enable_waf   = var.enable_waf
  waf_web_acl_arn = var.enable_waf ? module.waf.web_acl_arn : ""
  
  tags = local.common_tags
}

# ECS Module
module "ecs" {
  source = "../modules/ecs"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id  = module.security_groups.ecs_security_group_id
  alb_security_group_id = module.security_groups.alb_security_group_id
  api_gateway_url = module.api_gateway.api_gateway_url
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  ecs_execution_role_name = module.iam.ecs_execution_role_name
  ecs_task_role_arn = module.iam.ecs_task_role_arn
  kms_key_id = module.kms.kms_key_id
  certificate_arn = var.certificate_arn
  cpu = var.ecs_cpu
  memory = var.ecs_memory
  desired_count = var.ecs_desired_count
  
  tags = local.common_tags
}

# CloudFront Module
module "cloudfront" {
  source = "../modules/cloudfront"
  
  project_name = var.project_name
  environment  = var.environment
  api_gateway_domain = module.api_gateway.api_gateway_domain
  waf_web_acl_id = module.waf.web_acl_id
  
  tags = local.common_tags
}

# WAF Module
module "waf" {
  source = "../modules/waf"
  
  project_name = var.project_name
  environment  = var.environment
  kms_key_id   = module.kms.kms_key_id
  
  tags = local.common_tags
}

# Monitoring Module
module "monitoring" {
  source = "../modules/monitoring"
  
  project_name = var.project_name
  environment  = var.environment
  lambda_function_name = module.lambda.function_name
  ecs_service_name = module.ecs.service_name
  ecs_cluster_name = module.ecs.cluster_name
  api_gateway_name = module.api_gateway.api_gateway_name
  dynamodb_table_name = module.dynamodb.chat_history_table_name
  kms_key_id = module.kms.kms_key_id
  log_retention_days = var.log_retention_days
  
  tags = local.common_tags
}

# AWS Shield Module
module "shield" {
  source = "../modules/shield"
  
  project_name = var.project_name
  environment  = var.environment
  enable_shield_advanced = var.enable_shield_advanced
  resource_arn = module.api_gateway.api_gateway_arn
  
  tags = local.common_tags
}

# GuardDuty Module
module "guardduty" {
  source = "../modules/guardduty"
  
  project_name = var.project_name
  environment  = var.environment
  enable_guardduty = var.enable_guardduty
  enable_s3_protection = var.enable_guardduty_s3_protection
  enable_kubernetes_protection = var.enable_guardduty_kubernetes_protection
  enable_malware_protection = var.enable_guardduty_malware_protection
  kms_key_id = module.kms.kms_key_id
  
  tags = local.common_tags
}

# Amazon Inspector Module
module "inspector" {
  source = "../modules/inspector"
  
  project_name = var.project_name
  environment  = var.environment
  account_id   = data.aws_caller_identity.current.account_id
  enable_inspector = var.enable_inspector
  resource_types = var.inspector_resource_types
  enable_ec2_scanning = var.enable_inspector_ec2
  enable_ecr_scanning = var.enable_inspector_ecr
  enable_lambda_scanning = var.enable_inspector_lambda
  auto_run_assessment = var.enable_inspector_auto_run
  
  tags = local.common_tags
}

# Security Hub Module
module "security_hub" {
  source = "../modules/security-hub"
  
  project_name = var.project_name
  environment  = var.environment
  enable_security_hub = var.enable_security_hub
  enable_default_standards = var.enable_security_hub_default_standards
  enable_cis_standard = var.enable_security_hub_cis
  enable_pci_standard = var.enable_security_hub_pci
  enable_nist_standard = var.enable_security_hub_nist
  enable_finding_aggregation = var.enable_security_hub_aggregation
  
  tags = local.common_tags
}

# Security Lake Module
module "security_lake" {
  source = "../modules/security-lake"
  
  project_name = var.project_name
  environment  = var.environment
  account_id   = data.aws_caller_identity.current.account_id
  enable_security_lake = var.enable_security_lake
  kms_key_id = module.kms.kms_key_id
  
  tags = local.common_tags
}

# Bedrock Module - Only create if OpenSearch is enabled
module "bedrock" {
  count = var.opensearch_instance_count > 0 ? 1 : 0
  source = "../modules/bedrock"
  
  project_name = var.project_name
  environment  = var.environment
  bedrock_knowledge_base_role_arn = module.iam.bedrock_knowledge_base_role_arn
  opensearch_collection_arn = module.opensearch.collection_arn
  s3_bucket_arn = module.s3.documents_bucket_arn
  s3_bucket_name = module.s3.documents_bucket_name
  
  tags = local.common_tags
}

# WAF Web ACL Association (if enabled)
resource "aws_wafv2_web_acl_association" "api_gateway" {
  count = var.enable_waf ? 1 : 0
  
  resource_arn = module.api_gateway.api_gateway_stage_arn
  web_acl_arn  = module.waf.web_acl_arn
}