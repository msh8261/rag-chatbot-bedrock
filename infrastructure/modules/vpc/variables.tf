# VPC Module - Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
}

variable "bedrock_security_group_id" {
  description = "Security group ID for Bedrock VPC endpoint"
  type        = string
  default     = ""
}

variable "lambda_security_group_id" {
  description = "Security group ID for Lambda VPC endpoint"
  type        = string
  default     = ""
}

variable "opensearch_security_group_id" {
  description = "Security group ID for OpenSearch VPC endpoint"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
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

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for AWS services"
  type        = bool
  default     = true
}

variable "vpc_endpoint_security_group_ids" {
  description = "Security group IDs for VPC endpoints"
  type        = list(string)
  default     = []
}

# Route Configuration
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