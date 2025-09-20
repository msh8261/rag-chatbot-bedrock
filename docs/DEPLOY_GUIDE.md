# Complete Deployment Guide

This comprehensive guide will walk you through deploying the Secure RAG Chatbot from scratch to a fully functional, production-ready application.

## Table of Contents

1. [Prerequisites Setup](#prerequisites-setup)
2. [AWS Account Setup](#aws-account-setup)
3. [GitHub Repository Setup](#github-repository-setup)
4. [Infrastructure Deployment](#infrastructure-deployment)
5. [Application Deployment](#application-deployment)
6. [Bedrock Configuration](#bedrock-configuration)
7. [Testing the Deployment](#testing-the-deployment)
8. [Monitoring Setup](#monitoring-setup)
9. [Security Verification](#security-verification)
10. [Troubleshooting](#troubleshooting)
11. [Post-Deployment](#post-deployment)
12. [Cost Optimization](#cost-optimization)
13. [Next Steps](#next-steps)

## Prerequisites Setup

### 1. Install Required Tools

#### Windows (PowerShell)
```powershell
# Install Chocolatey (if not already installed)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install required tools
choco install terraform awscli docker-desktop python3 git -y

# Verify installations
terraform --version
aws --version
docker --version
python3 --version
git --version
```

#### macOS (Homebrew)
```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install terraform awscli docker python3 git

# Verify installations
terraform --version
aws --version
docker --version
python3 --version
git --version
```

#### Linux (Ubuntu/Debian)
```bash
# Update package list
sudo apt update

# Install required tools
sudo apt install -y terraform awscli docker.io python3 python3-pip git

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group (optional, for non-sudo usage)
sudo usermod -aG docker $USER
newgrp docker

# Verify installations
terraform --version
aws --version
docker --version
python3 --version
git --version
```

### 2. Python Dependencies
```bash
# Install Python packages
pip3 install boto3 streamlit requests python-dotenv

# Verify Python packages
python3 -c "import boto3, streamlit, requests; print('All packages installed successfully')"
```

## AWS Account Setup

### 3. Create AWS Account
1. Go to [AWS Console](https://aws.amazon.com/console/)
2. Click "Create an AWS Account"
3. Follow the registration process:
   - Enter account information
   - Choose account type (Personal or Business)
   - Add payment information
   - Verify phone number
   - Choose support plan (Basic is sufficient for testing)

### 4. Configure AWS CLI
```bash
# Configure AWS credentials
aws configure

# Enter the following when prompted:
# AWS Access Key ID: [Your Access Key]
# AWS Secret Access Key: [Your Secret Key]
# Default region name: us-east-1
# Default output format: json

# Test configuration
aws sts get-caller-identity
```

**Expected Output:**
```json
{
    "UserId": "AIDACKCEVSQ6C2EXAMPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-username"
}
```

### 5. Create IAM User (Recommended for Production)
1. Go to [AWS IAM Console](https://console.aws.amazon.com/iam/)
2. Click "Users" → "Create user"
3. Enter username: `rag-chatbot-deployer`
4. Select "Programmatic access"
5. Attach policies:
   - `AdministratorAccess` (for initial setup)
   - Or create custom policies with specific permissions
6. Review and create user
7. **Important**: Save the Access Key ID and Secret Access Key

### 6. Set up AWS Service Quotas
Some services may require quota increases:

```bash
# Check current quotas
aws service-quotas get-service-quota \
  --service-code ec2 \
  --quota-code L-0263D0A3

# Request quota increase if needed (via AWS Console)
# Go to Service Quotas → EC2 → Running On-Demand F and G instances
```

## GitHub Repository Setup

### 7. Fork/Clone Repository
```bash
# Clone the repository
git clone https://github.com/your-username/RAG-CHATBOT-BEDROCK.git
cd RAG-CHATBOT-BEDROCK

# Or if you're working with the current directory
git init
git remote add origin https://github.com/your-username/RAG-CHATBOT-BEDROCK.git
```

### 8. Set up GitHub Actions Secrets
1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AWS_ACCESS_KEY_ID` | `AKIA...` | Your AWS access key |
| `AWS_SECRET_ACCESS_KEY` | `...` | Your AWS secret key |
| `AWS_ACCOUNT_ID` | `123456789012` | Your AWS account ID |

### 9. Enable GitHub Actions
1. Go to **Actions** tab in your repository
2. Click **I understand my workflows, go ahead and enable them**

## Infrastructure Deployment

### 10. Configure Terraform Variables
```bash
# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit the variables file
notepad terraform.tfvars  # Windows
# or
nano terraform.tfvars     # Linux/macOS
# or
code terraform.tfvars     # VS Code
```

**Update terraform.tfvars with your values:**
```hcl
# Basic Configuration
aws_region = "us-east-1"
project_name = "rag-chatbot"
environment = "prod"

# Optional: Domain Configuration (leave empty for now)
# domain_name = "your-domain.com"
# certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/your-cert-id"

# Resource Configuration
ecs_cpu = 512
ecs_memory = 1024
ecs_desired_count = 2

# Security Configuration
enable_cloudfront = true
enable_waf = true
enable_monitoring = true

# Cost Optimization (for testing)
log_retention_days = 7
backup_retention_days = 1
```

### 11. Deploy Infrastructure
```bash
# Navigate to Terraform directory
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Review the deployment plan (this may take a few minutes)
terraform plan

# Deploy the infrastructure (this will take 10-15 minutes)
terraform apply

# Confirm with 'yes' when prompted
# Type: yes
```

**Expected Output:**
```
Apply complete! Resources: 45 added, 0 changed, 0 destroyed.

Outputs:

api_gateway_url = "https://abc123def4.execute-api.us-east-1.amazonaws.com/prod"
application_url = "https://d1234567890.cloudfront.net"
cloudfront_domain_name = "d1234567890.cloudfront.net"
dynamodb_table_name = "rag-chatbot-prod-chat-history"
s3_bucket_name = "rag-chatbot-prod-documents-abc123"
...
```

### 12. Save Important Outputs
```bash
# Get all outputs
terraform output -json > outputs.json

# Get specific outputs
terraform output api_gateway_url
terraform output application_url
terraform output s3_bucket_name
terraform output dynamodb_table_name
```

## Application Deployment

### 13. Build and Deploy Frontend
```bash
# Navigate to frontend directory
cd application/frontend

# Build Docker image
docker build -t rag-chatbot-frontend .

# Get your AWS account ID and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)

# Create ECR repository (if it doesn't exist)
aws ecr create-repository --repository-name rag-chatbot-frontend --region $AWS_REGION || true

# Tag for ECR
docker tag rag-chatbot-frontend:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/rag-chatbot-frontend:latest

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Push to ECR
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/rag-chatbot-frontend:latest
```

### 14. Deploy Lambda Function
```bash
# Navigate to backend directory
cd application/backend

# Install dependencies
pip3 install -r requirements.txt -t .

# Create deployment package
zip -r lambda-deployment.zip .

# Get Lambda function name from Terraform output
LAMBDA_FUNCTION_NAME=$(cd ../../infrastructure/terraform && terraform output -raw lambda_function_name)

# Update Lambda function
aws lambda update-function-code \
  --function-name $LAMBDA_FUNCTION_NAME \
  --zip-file fileb://lambda-deployment.zip

# Clean up
rm -rf boto3* botocore* opensearch* langchain* lambda-deployment.zip
```

### 15. Update ECS Service
```bash
# Get ECS cluster and service names
ECS_CLUSTER_NAME=$(cd ../../infrastructure/terraform && terraform output -raw ecs_cluster_name)
ECS_SERVICE_NAME=$(cd ../../infrastructure/terraform && terraform output -raw ecs_service_name)

# Force new deployment to use the new image
aws ecs update-service \
  --cluster $ECS_CLUSTER_NAME \
  --service $ECS_SERVICE_NAME \
  --force-new-deployment

# Wait for deployment to complete (this may take 5-10 minutes)
aws ecs wait services-stable \
  --cluster $ECS_CLUSTER_NAME \
  --services $ECS_SERVICE_NAME

# Check service status
aws ecs describe-services \
  --cluster $ECS_CLUSTER_NAME \
  --services $ECS_SERVICE_NAME \
  --query 'services[0].deployments[0].{Status:status,RunningCount:runningCount,DesiredCount:desiredCount}'
```

## Bedrock Configuration

### 16. Enable Bedrock Models
1. Go to [Amazon Bedrock Console](https://console.aws.amazon.com/bedrock/)
2. Navigate to **"Model access"** in the left sidebar
3. Click **"Manage model access"**
4. Request access to:
   - **Claude 3 Sonnet** (anthropic.claude-3-sonnet-20240229-v1:0)
   - **Amazon Titan Embeddings** (amazon.titan-embed-text-v1)
5. Click **"Save changes"**
6. Wait for approval (usually instant)

### 17. Create Knowledge Base
1. In Bedrock Console, go to **"Knowledge bases"**
2. Click **"Create knowledge base"**
3. Configure the knowledge base:

**Step 1: Knowledge base details**
- **Knowledge base name**: `rag-chatbot-knowledge-base`
- **Description**: `Knowledge base for RAG chatbot documents`

**Step 2: IAM permissions**
- **Service role**: Select the role created by Terraform (search for `rag-chatbot-prod-bedrock-kb-role`)

**Step 3: Data source**
- **S3 bucket**: Select the bucket created by Terraform (search for `rag-chatbot-prod-documents`)
- **S3 prefix**: `documents/`
- **Chunking strategy**: `Fixed size chunking`
- **Chunk size**: `300 tokens`
- **Overlap**: `20 tokens`

**Step 4: Embeddings**
- **Embedding model**: `Amazon Titan Embeddings v1`
- **Vector index name**: `bedrock-knowledge-base`

4. Click **"Create knowledge base"**
5. Wait for creation to complete (5-10 minutes)

### 18. Upload Sample Documents
```bash
# Get S3 bucket name
S3_BUCKET_NAME=$(cd ../../infrastructure/terraform && terraform output -raw s3_bucket_name)

# Create sample documents
mkdir -p sample-docs
cat > sample-docs/ai-basics.txt << EOF
Artificial Intelligence (AI) is a branch of computer science that aims to create intelligent machines that can perform tasks that typically require human intelligence. These tasks include learning, reasoning, problem-solving, perception, and language understanding.

Machine Learning is a subset of AI that focuses on the development of algorithms and statistical models that enable computer systems to improve their performance on a specific task through experience, without being explicitly programmed.

Deep Learning is a subset of machine learning that uses artificial neural networks with multiple layers to model and understand complex patterns in data. It has been particularly successful in areas such as image recognition, natural language processing, and speech recognition.
EOF

cat > sample-docs/rag-explained.txt << EOF
Retrieval-Augmented Generation (RAG) is a technique that combines the power of large language models with external knowledge retrieval to provide more accurate and up-to-date responses.

RAG works by:
1. Retrieving relevant documents from a knowledge base based on the user's query
2. Using these documents as context for the language model
3. Generating responses that are grounded in the retrieved information

This approach helps reduce hallucinations and provides more factual, reliable responses by giving the model access to specific, relevant information.
EOF

# Upload documents to S3
aws s3 cp sample-docs/ s3://$S3_BUCKET_NAME/documents/ --recursive

# Verify upload
aws s3 ls s3://$S3_BUCKET_NAME/documents/
```

### 19. Ingest Documents into Knowledge Base
1. Go back to the Bedrock Console → Knowledge bases
2. Click on your knowledge base
3. Go to **"Data sources"** tab
4. Click **"Sync"** next to your data source
5. Wait for ingestion to complete (5-10 minutes)

## Testing the Deployment

### 20. Test API Endpoint
```bash
# Get API Gateway URL
API_URL=$(cd ../../infrastructure/terraform && terraform output -raw api_gateway_url)

# Test the API with a simple message
curl -X POST $API_URL/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "What is artificial intelligence?",
    "session_id": "test-session-123",
    "user_id": "test-user"
  }'

# Expected response:
# {
#   "response": "Artificial Intelligence (AI) is a branch of computer science...",
#   "session_id": "test-session-123",
#   "timestamp": "2024-01-15T10:30:00.000Z"
# }
```

### 21. Test Frontend Application
1. Get the CloudFront URL:
   ```bash
   cd ../../infrastructure/terraform
   terraform output -raw application_url
   ```

2. Open the URL in your browser
3. You should see the RAG Chatbot interface
4. Test the chat functionality:
   - Type: "Hello, can you help me with AI?"
   - Type: "What is RAG?"
   - Type: "Explain machine learning"

### 22. Test Knowledge Base Integration
```bash
# Test with a question that should retrieve from your uploaded documents
curl -X POST $API_URL/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "How does RAG work?",
    "session_id": "test-session-456",
    "user_id": "test-user"
  }'
```

## Monitoring Setup

### 23. Set up CloudWatch Dashboard
1. Go to [CloudWatch Console](https://console.aws.amazon.com/cloudwatch/)
2. Navigate to **"Dashboards"**
3. Find the dashboard: `rag-chatbot-prod-dashboard`
4. Review the metrics:
   - Lambda invocations and errors
   - ECS CPU and memory utilization
   - API Gateway request count and latency
   - DynamoDB read/write capacity

### 24. Configure Alerts
1. In CloudWatch, go to **"Alarms"**
2. Create alarms for:
   - **High error rate**: Lambda errors > 5%
   - **High latency**: API Gateway latency > 5 seconds
   - **Resource utilization**: ECS CPU > 80%

### 25. Set up SNS Notifications
```bash
# Create SNS topic
aws sns create-topic --name rag-chatbot-alerts

# Subscribe to email notifications
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:123456789012:rag-chatbot-alerts \
  --protocol email \
  --notification-endpoint your-email@example.com
```

## Security Verification

### 26. Verify WAF Protection
```bash
# Get WAF Web ACL ARN
WAF_ARN=$(cd ../../infrastructure/terraform && terraform output -raw waf_web_acl_arn)

# Check WAF rules
aws wafv2 get-web-acl --scope REGIONAL --id $(echo $WAF_ARN | cut -d'/' -f3)
```

### 27. Verify VPC Endpoints
```bash
# Check VPC endpoints
aws ec2 describe-vpc-endpoints \
  --query 'VpcEndpoints[?contains(Tags[?Key==`Project`].Value, `rag-chatbot`)].{ServiceName:ServiceName,State:State}' \
  --output table
```

### 28. Verify Encryption
```bash
# Check S3 bucket encryption
S3_BUCKET_NAME=$(cd ../../infrastructure/terraform && terraform output -raw s3_bucket_name)
aws s3api get-bucket-encryption --bucket $S3_BUCKET_NAME

# Check DynamoDB encryption
DDB_TABLE_NAME=$(cd ../../infrastructure/terraform && terraform output -raw dynamodb_table_name)
aws dynamodb describe-table --table-name $DDB_TABLE_NAME --query 'Table.SSEDescription'
```

### 29. Test Security Features
1. **WAF Testing**: Try accessing the API with malicious payloads
2. **Rate Limiting**: Send multiple requests quickly
3. **Input Validation**: Test with various input types

## Troubleshooting

### 30. Common Issues and Solutions

#### Lambda Function Errors
```bash
# Check Lambda logs
aws logs tail /aws/lambda/rag-chatbot-prod-rag-chatbot --follow

# Check Lambda configuration
aws lambda get-function --function-name rag-chatbot-prod-rag-chatbot

# Common fixes:
# - Check IAM permissions
# - Verify environment variables
# - Check VPC configuration
```

#### ECS Service Issues
```bash
# Check ECS service status
aws ecs describe-services \
  --cluster rag-chatbot-prod-cluster \
  --services rag-chatbot-prod-service

# Check task logs
aws logs tail /aws/ecs/rag-chatbot-prod --follow

# Common fixes:
# - Check task definition
# - Verify container image
# - Check load balancer health
```

#### API Gateway Problems
```bash
# Check API Gateway logs
aws logs tail /aws/apigateway/rag-chatbot-prod-api --follow

# Test API Gateway directly
aws apigateway get-rest-apis

# Common fixes:
# - Check Lambda integration
# - Verify CORS configuration
# - Check WAF rules
```

#### Bedrock Access Issues
```bash
# Check Bedrock model access
aws bedrock list-foundation-models

# Check IAM permissions
aws iam get-role-policy \
  --role-name rag-chatbot-prod-lambda-role \
  --policy-name lambda-bedrock-policy

# Common fixes:
# - Verify model access
# - Check IAM permissions
# - Verify region availability
```

### 31. Debug Commands
```bash
# Check all resources
cd ../../infrastructure/terraform
terraform show

# Check specific resource
terraform state show aws_lambda_function.main

# Import existing resource (if needed)
terraform import aws_s3_bucket.documents bucket-name
```

## Post-Deployment

### 32. Set up Monitoring
1. **CloudWatch Alarms**: Set up alerts for key metrics
2. **SNS Notifications**: Configure email/SMS alerts
3. **Security Hub**: Review security findings
4. **GuardDuty**: Monitor for threats

### 33. Document Configuration
```bash
# Save all important outputs
cd ../../infrastructure/terraform
terraform output -json > ../../deployment-outputs.json

# Create deployment summary
cat > ../../deployment-summary.md << EOF
# Deployment Summary

## Infrastructure
- API Gateway URL: $(terraform output -raw api_gateway_url)
- Application URL: $(terraform output -raw application_url)
- S3 Bucket: $(terraform output -raw s3_bucket_name)
- DynamoDB Table: $(terraform output -raw dynamodb_table_name)

## Security
- WAF Web ACL: $(terraform output -raw waf_web_acl_arn)
- KMS Key: $(terraform output -raw kms_key_arn)

## Monitoring
- Dashboard: $(terraform output -raw monitoring_dashboard_url)
- Log Groups: /aws/lambda/rag-chatbot-prod-rag-chatbot

## Next Steps
1. Upload more documents to S3
2. Configure custom domain (optional)
3. Set up monitoring alerts
4. Review security settings
EOF
```

### 34. Implement Backup Strategy
```bash
# Enable DynamoDB point-in-time recovery
aws dynamodb update-continuous-backups \
  --table-name $DDB_TABLE_NAME \
  --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true

# Set up S3 lifecycle policies
aws s3api put-bucket-lifecycle-configuration \
  --bucket $S3_BUCKET_NAME \
  --lifecycle-configuration file://lifecycle.json
```

## Cost Optimization

### 35. Implement Cost Controls
```bash
# Set up AWS Budgets
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget '{
    "BudgetName": "RAG-Chatbot-Budget",
    "BudgetLimit": {"Amount": "300", "Unit": "USD"},
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST",
    "CostFilters": {
      "Service": ["Amazon Elastic Compute Cloud", "Amazon Bedrock", "Amazon DynamoDB"]
    }
  }'
```

### 36. Monitor Costs
1. Go to [AWS Cost Explorer](https://console.aws.amazon.com/cost-management/home#/cost-explorer)
2. Set up cost alerts
3. Review daily costs
4. Identify optimization opportunities

## Next Steps

### 37. Production Readiness Checklist
- [ ] **Load Testing**: Test with realistic traffic patterns
- [ ] **Security Audit**: Review all security settings
- [ ] **Backup Strategy**: Implement data backup procedures
- [ ] **Disaster Recovery**: Test failover procedures
- [ ] **Documentation**: Update all documentation
- [ ] **Monitoring**: Set up comprehensive monitoring
- [ ] **Alerting**: Configure alert thresholds
- [ ] **Cost Optimization**: Implement cost controls

### 38. Maintenance Tasks
- [ ] **Regular Updates**: Keep dependencies updated
- [ ] **Security Patches**: Apply security updates
- [ ] **Cost Reviews**: Monthly cost optimization
- [ ] **Performance Monitoring**: Regular performance reviews
- [ ] **Backup Testing**: Test backup and recovery procedures

### 39. Scaling Considerations
- [ ] **Auto Scaling**: Configure ECS auto scaling
- [ ] **Lambda Concurrency**: Set appropriate limits
- [ ] **Database Scaling**: Configure DynamoDB auto scaling
- [ ] **CDN Optimization**: Optimize CloudFront settings

## Quick Deployment Script

For automated deployment, use the provided script:

```bash
# Make the script executable
chmod +x scripts/deploy.sh

# Run full deployment
./scripts/deploy.sh

# Or run specific parts
./scripts/deploy.sh infrastructure
./scripts/deploy.sh application
./scripts/deploy.sh test
```

## Support and Resources

### Documentation
- [AWS Bedrock Documentation](https://docs.aws.amazon.com/bedrock/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Streamlit Documentation](https://docs.streamlit.io/)

### Community
- [AWS Forums](https://forums.aws.amazon.com/)
- [Terraform Community](https://discuss.hashicorp.com/c/terraform-core)
- [GitHub Issues](https://github.com/your-repo/issues)

### Professional Support
- [AWS Support](https://aws.amazon.com/support/)
- [Terraform Support](https://www.hashicorp.com/support)

---

## Summary

This deployment guide provides a complete walkthrough from initial setup to production deployment. The entire process typically takes 30-45 minutes, depending on your AWS region and internet speed.

**Key milestones:**
1. ✅ Prerequisites installed
2. ✅ AWS account configured
3. ✅ Infrastructure deployed
4. ✅ Application deployed
5. ✅ Bedrock configured
6. ✅ Testing completed
7. ✅ Monitoring set up
8. ✅ Security verified

**Expected costs:** ~$10-15 per day for moderate usage

**Next steps:** Upload your documents, configure monitoring, and start using your secure RAG chatbot!

For questions or issues, refer to the troubleshooting section or create an issue in the GitHub repository.
