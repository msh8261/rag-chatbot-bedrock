# Terraform Configuration Guide

This document explains how to configure the RAG Chatbot infrastructure using Terraform variables.

## Configuration Files

### 1. `terraform.tfvars` (Main Configuration)
This file contains the actual configuration values for your deployment. **Never commit this file to version control** as it may contain sensitive information.

### 2. `terraform.tfvars.example` (Template)
This file serves as a template showing all available configuration options with example values.

### 3. `variables.tf` (Variable Definitions)
This file defines all the variables used in the Terraform configuration with their types, descriptions, and default values.

## Configuration Categories

### Basic Configuration
```hcl
project_name = "rag-chatbot"    # Name of your project
environment  = "prod"           # Environment (dev, staging, prod)
aws_region   = "ap-southeast-1" # AWS region for deployment
```

### Domain Configuration (Optional)
```hcl
domain_name     = ""            # Custom domain name (optional)
certificate_arn = ""            # ACM certificate ARN for HTTPS (optional)
```
If you don't have a custom domain, leave these empty and the application will use the ALB URL.

### VPC Configuration
```hcl
vpc_cidr = "10.0.0.0/16"       # VPC CIDR block
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
database_subnet_cidrs = ["10.0.30.0/24", "10.0.40.0/24"]
availability_zones_count = 2    # Number of AZs to use
```

### Security Configuration
```hcl
enable_private_subnets = true   # Use private subnets for app components
enable_vpc_endpoints   = true   # Enable VPC endpoints for AWS services
enable_guardrails      = true   # Enable Bedrock guardrails
enable_encryption      = true   # Enable encryption for all resources
enable_waf            = true    # Enable AWS WAF
enable_monitoring     = true    # Enable comprehensive monitoring
```

### Application Configuration
```hcl
bedrock_model_id = "anthropic.claude-3-sonnet-20240229-v1:0"
```

### Lambda Configuration
```hcl
lambda_memory_size = 512        # Memory in MB
lambda_timeout     = 30         # Timeout in seconds
lambda_function_filename = "lambda_function"  # Lambda function filename (without .py)
```

**Lambda Function Options**:
- `"lambda_function"` - Full RAG chatbot with Bedrock integration (default)
- `"lambda_function_simple"` - Simplified version for testing/debugging
- Custom filename - Use your own Lambda function file

### ECS Configuration
```hcl
ecs_cpu          = 512          # CPU units (256 = 0.25 vCPU)
ecs_memory       = 1024         # Memory in MB
ecs_desired_count = 2           # Number of ECS tasks
```

### API Gateway Configuration
```hcl
rate_limit  = 100               # Requests per second
burst_limit = 200               # Burst limit
max_concurrent_requests = 1000  # Max concurrent requests
```

### Logging and Backup Configuration
```hcl
log_retention_days   = 30       # CloudWatch log retention
backup_retention_days = 7       # Backup retention period
```

### Network Access Configuration
```hcl
# For public access:
allowed_cidr_blocks = ["0.0.0.0/0"]

# For restricted access:
allowed_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
```

## Environment-Specific Configurations

### Development Environment
```hcl
environment = "dev"
ecs_desired_count = 1
lambda_memory_size = 256
ecs_cpu = 256
ecs_memory = 512
log_retention_days = 7
```

### Production Environment
```hcl
environment = "prod"
ecs_desired_count = 3
lambda_memory_size = 1024
ecs_cpu = 1024
ecs_memory = 2048
log_retention_days = 30
```

## Custom Domain Setup

To use a custom domain:

1. **Request an ACM Certificate**:
   ```bash
   aws acm request-certificate \
     --domain-name your-domain.com \
     --validation-method DNS \
     --region us-east-1
   ```

2. **Update terraform.tfvars**:
   ```hcl
   domain_name     = "your-domain.com"
   certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
   ```

3. **Deploy the infrastructure**:
   ```bash
   terraform apply
   ```

## Security Considerations

### Network Access
- **Public Access**: Set `allowed_cidr_blocks = ["0.0.0.0/0"]` for public access
- **Restricted Access**: Specify specific CIDR blocks for your organization's IP ranges
- **VPN Access**: Use your VPN's CIDR block for secure access

### Encryption
- All resources use encryption by default (`enable_encryption = true`)
- KMS keys are created automatically for encryption
- VPC endpoints ensure traffic stays within AWS network

### Monitoring
- CloudWatch dashboards and alarms are enabled by default
- Log retention can be configured based on compliance requirements
- WAF provides additional security layer

## Cost Optimization

### Development Environment
```hcl
ecs_desired_count = 1
lambda_memory_size = 256
ecs_cpu = 256
ecs_memory = 512
log_retention_days = 7
backup_retention_days = 1
```

### Production Environment
```hcl
ecs_desired_count = 3
lambda_memory_size = 1024
ecs_cpu = 1024
ecs_memory = 2048
log_retention_days = 30
backup_retention_days = 7
```

## Troubleshooting

### Common Issues

1. **Certificate ARN Region Mismatch**: Ensure certificate is in `us-east-1` for CloudFront
2. **VPC CIDR Conflicts**: Ensure VPC CIDR doesn't conflict with existing networks
3. **Availability Zone Count**: Must be 2 or 3 for high availability
4. **Memory/CPU Ratios**: ECS tasks require specific CPU/memory ratios

### Validation Commands

```bash
# Validate Terraform configuration
terraform validate

# Plan deployment
terraform plan

# Check for unused variables
terraform plan -var-file=terraform.tfvars
```

## Best Practices

1. **Use terraform.tfvars.example** as a template
2. **Never commit terraform.tfvars** to version control
3. **Use environment-specific files** (e.g., `terraform.tfvars.prod`)
4. **Validate configurations** before applying
5. **Use meaningful project names** and environment names
6. **Review security settings** before production deployment
7. **Monitor costs** using AWS Cost Explorer
8. **Regular backups** and log retention policies
