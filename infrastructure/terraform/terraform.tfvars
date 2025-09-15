# RAG Chatbot Infrastructure Configuration
# This file contains all the configuration values for the Terraform deployment

# Basic Configuration
project_name = "rag-chatbot"
environment  = "prod"
aws_region   = "ap-southeast-1"

# Domain Configuration (optional - leave empty for ALB-only deployment)
domain_name     = ""
certificate_arn = ""

# VPC Configuration
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
database_subnet_cidrs = ["10.0.30.0/24", "10.0.40.0/24"]
availability_zones_count = 2

# Security Configuration
enable_private_subnets = true
enable_vpc_endpoints   = true
enable_guardrails      = true
enable_encryption      = true
enable_waf            = true
enable_monitoring     = true

# Application Configuration
bedrock_model_id = "anthropic.claude-3-sonnet-20240229-v1:0"

# Lambda Configuration
lambda_memory_size = 512
lambda_timeout     = 30
lambda_function_filename = "lambda_function"

# ECS Configuration
ecs_cpu          = 512
ecs_memory       = 1024
ecs_desired_count = 2

# API Gateway Configuration
rate_limit  = 100
burst_limit = 200
max_concurrent_requests = 1000

# OpenSearch Configuration (commented out - requires subscription)
# opensearch_instance_type  = "t3.small.search"
# opensearch_instance_count = 1

# CloudFront Configuration
enable_cloudfront = false

# Logging and Backup Configuration
log_retention_days   = 30
backup_retention_days = 7

# Network Access Configuration
allowed_cidr_blocks = ["0.0.0.0/0"]

# Note: Terraform version and provider version are hardcoded in main.tf

# Default Tags Configuration
managed_by = "Terraform"
security_level = "High"

# Availability Zones Configuration
availability_zones_state = "available"

# VPC Configuration
enable_dns_hostnames = true
enable_dns_support   = true
enable_nat_gateway   = true
public_route_cidr    = "0.0.0.0/0"
private_route_cidr   = "0.0.0.0/0"
