# RAG Chatbot Infrastructure - Variables

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "rag-chatbot"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
  default     = ""
}

variable "bedrock_model_id" {
  description = "Bedrock model ID to use"
  type        = string
  default     = "anthropic.claude-3-sonnet-20240229-v1:0"
}

variable "opensearch_instance_type" {
  description = "OpenSearch instance type"
  type        = string
  default     = "t3.small.search"
}

variable "opensearch_instance_count" {
  description = "Number of OpenSearch instances"
  type        = number
  default     = 1
}

variable "lambda_memory_size" {
  description = "Lambda function memory size"
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Lambda function timeout"
  type        = number
  default     = 30
}

variable "ecs_cpu" {
  description = "ECS task CPU units"
  type        = number
  default     = 512
}

variable "ecs_memory" {
  description = "ECS task memory"
  type        = number
  default     = 1024
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "enable_cloudfront" {
  description = "Enable CloudFront distribution"
  type        = bool
  default     = true
}

variable "enable_waf" {
  description = "Enable AWS WAF"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable comprehensive monitoring"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the application"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_encryption" {
  description = "Enable encryption for all resources"
  type        = bool
  default     = true
}


# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.30.0/24", "10.0.40.0/24"]
}

variable "availability_zones_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 2
}

# Security Configuration
variable "enable_private_subnets" {
  description = "Use private subnets for application components"
  type        = bool
  default     = true
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for AWS services"
  type        = bool
  default     = true
}

variable "enable_guardrails" {
  description = "Enable Bedrock guardrails"
  type        = bool
  default     = true
}

# Application Configuration
variable "max_concurrent_requests" {
  description = "Maximum concurrent requests for API Gateway"
  type        = number
  default     = 1000
}

variable "rate_limit" {
  description = "API Gateway rate limit per second"
  type        = number
  default     = 100
}

variable "burst_limit" {
  description = "API Gateway burst limit"
  type        = number
  default     = 200
}

# Lambda Configuration
variable "lambda_function_filename" {
  description = "Lambda function filename (without .py extension)"
  type        = string
  default     = "lambda_function"
}

# Note: Terraform version and provider version cannot be variables
# They must be hardcoded in the terraform block

# Default Tags Configuration
variable "managed_by" {
  description = "Value for ManagedBy tag"
  type        = string
  default     = "Terraform"
}

variable "security_level" {
  description = "Security level for default tags"
  type        = string
  default     = "High"
}

# Security Services Configuration
variable "enable_shield_advanced" {
  description = "Enable AWS Shield Advanced protection"
  type        = bool
  default     = false
}

variable "enable_guardduty" {
  description = "Enable GuardDuty threat detection"
  type        = bool
  default     = false
}

variable "enable_guardduty_s3_protection" {
  description = "Enable S3 protection in GuardDuty"
  type        = bool
  default     = true
}

variable "enable_guardduty_kubernetes_protection" {
  description = "Enable Kubernetes protection in GuardDuty"
  type        = bool
  default     = false
}

variable "enable_guardduty_malware_protection" {
  description = "Enable malware protection in GuardDuty"
  type        = bool
  default     = true
}

variable "enable_inspector" {
  description = "Enable Amazon Inspector vulnerability assessment"
  type        = bool
  default     = false
}

variable "inspector_resource_types" {
  description = "Resource types to enable for Inspector scanning"
  type        = list(string)
  default     = ["EC2", "ECR", "LAMBDA"]
}

variable "enable_inspector_ec2" {
  description = "Enable EC2 scanning in Inspector"
  type        = bool
  default     = true
}

variable "enable_inspector_ecr" {
  description = "Enable ECR scanning in Inspector"
  type        = bool
  default     = true
}

variable "enable_inspector_lambda" {
  description = "Enable Lambda scanning in Inspector"
  type        = bool
  default     = true
}

variable "enable_inspector_auto_run" {
  description = "Automatically run Inspector assessment"
  type        = bool
  default     = false
}

variable "enable_security_hub" {
  description = "Enable AWS Security Hub"
  type        = bool
  default     = false
}

variable "enable_security_hub_default_standards" {
  description = "Enable default security standards in Security Hub"
  type        = bool
  default     = true
}

variable "enable_security_hub_cis" {
  description = "Enable CIS AWS Foundations Benchmark in Security Hub"
  type        = bool
  default     = true
}

variable "enable_security_hub_pci" {
  description = "Enable PCI DSS standard in Security Hub"
  type        = bool
  default     = false
}

variable "enable_security_hub_nist" {
  description = "Enable NIST Cybersecurity Framework in Security Hub"
  type        = bool
  default     = true
}

variable "enable_security_hub_aggregation" {
  description = "Enable finding aggregation across regions in Security Hub"
  type        = bool
  default     = false
}

variable "enable_security_lake" {
  description = "Enable AWS Security Lake"
  type        = bool
  default     = false
}

# Availability Zones Configuration
variable "availability_zones_state" {
  description = "State filter for availability zones"
  type        = string
  default     = "available"
}

# VPC Configuration
variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "public_route_cidr" {
  description = "CIDR block for public route to internet gateway"
  type        = string
  default     = "0.0.0.0/0"
}

variable "private_route_cidr" {
  description = "CIDR block for private route to NAT gateway"
  type        = string
  default     = "0.0.0.0/0"
}