# Deployment Guide

This guide provides step-by-step instructions for deploying the Secure RAG Chatbot infrastructure and application.

## Prerequisites

### Required Tools
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) >= 2.0
- [Docker](https://www.docker.com/get-started) >= 20.0
- [Python](https://www.python.org/downloads/) >= 3.11
- [Git](https://git-scm.com/downloads)

### AWS Account Setup
1. Create an AWS account
2. Configure AWS CLI with appropriate credentials
3. Ensure you have the necessary permissions for:
   - VPC, EC2, ECS, Lambda, API Gateway
   - DynamoDB, S3, OpenSearch
   - Bedrock, KMS, IAM
   - CloudWatch, CloudTrail, Security Hub

### GitHub Repository Setup
1. Fork or clone this repository
2. Set up GitHub Actions secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_ACCOUNT_ID`

## Infrastructure Deployment

### 1. Deploy Core Infrastructure

```bash
# Navigate to infrastructure directory
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the infrastructure
terraform apply
```

### 2. Configure Bedrock Models

After infrastructure deployment, you need to enable Bedrock models:

```bash
# Enable Claude 3 Sonnet
aws bedrock put-model-invocation-logging-configuration \
  --logging-config '{
    "textDataDeliveryEnabled": true,
    "embeddingDataDeliveryEnabled": true,
    "imageDataDeliveryEnabled": true,
    "s3Config": {
      "bucketName": "your-logging-bucket",
      "keyPrefix": "bedrock-logs/"
    }
  }'
```

### 3. Set up Knowledge Base

1. Upload documents to the S3 bucket:
```bash
aws s3 cp your-documents/ s3://your-documents-bucket/documents/ --recursive
```

2. Create the knowledge base in Bedrock console or via CLI

## Application Deployment

### 1. Build and Push Container Images

```bash
# Build frontend image
cd application/frontend
docker build -t rag-chatbot-frontend .
docker tag rag-chatbot-frontend:latest your-ecr-repo/rag-chatbot-frontend:latest
docker push your-ecr-repo/rag-chatbot-frontend:latest
```

### 2. Deploy Lambda Function

```bash
# Package Lambda function
cd application/backend
pip install -r requirements.txt -t .
zip -r lambda-deployment.zip .

# Update Lambda function
aws lambda update-function-code \
  --function-name rag-chatbot-prod-rag-chatbot \
  --zip-file fileb://lambda-deployment.zip
```

### 3. Update ECS Service

```bash
# Force new deployment
aws ecs update-service \
  --cluster rag-chatbot-prod-cluster \
  --service rag-chatbot-prod-service \
  --force-new-deployment
```

## Configuration

### Environment Variables

Set the following environment variables:

```bash
# API Gateway URL
export API_GATEWAY_URL="https://your-api-gateway-url.execute-api.region.amazonaws.com/prod"

# Environment
export ENVIRONMENT="prod"

# DynamoDB Table
export DYNAMODB_TABLE_NAME="rag-chatbot-prod-chat-history"

# OpenSearch Endpoint
export OPENSEARCH_ENDPOINT="https://your-opensearch-domain.region.es.amazonaws.com"

# S3 Bucket
export S3_BUCKET_NAME="rag-chatbot-prod-documents"
```

### Security Configuration

1. **WAF Rules**: Configure custom rules for your use case
2. **Rate Limiting**: Adjust API Gateway throttling limits
3. **VPC Endpoints**: Ensure all services use VPC endpoints
4. **IAM Policies**: Review and adjust IAM policies as needed

## Monitoring and Logging

### CloudWatch Dashboard
Access the CloudWatch dashboard to monitor:
- Lambda function metrics
- ECS service metrics
- API Gateway metrics
- DynamoDB metrics

### Security Monitoring
- Security Hub findings
- GuardDuty alerts
- CloudTrail logs
- WAF logs

### Log Analysis
- Application logs in CloudWatch Logs
- API Gateway access logs
- Lambda execution logs

## Troubleshooting

### Common Issues

1. **Lambda Function Errors**
   - Check CloudWatch logs
   - Verify IAM permissions
   - Check VPC configuration

2. **ECS Service Issues**
   - Check task definition
   - Verify container image
   - Check load balancer health

3. **API Gateway Problems**
   - Check Lambda integration
   - Verify CORS configuration
   - Check WAF rules

4. **Bedrock Access Issues**
   - Verify model access
   - Check IAM permissions
   - Verify region availability

### Debug Commands

```bash
# Check Lambda function logs
aws logs tail /aws/lambda/rag-chatbot-prod-rag-chatbot --follow

# Check ECS service status
aws ecs describe-services --cluster rag-chatbot-prod-cluster --services rag-chatbot-prod-service

# Check API Gateway logs
aws logs tail /aws/apigateway/rag-chatbot-prod-api --follow

# Check DynamoDB table
aws dynamodb describe-table --table-name rag-chatbot-prod-chat-history
```

## Security Considerations

### Data Protection
- All data is encrypted at rest and in transit
- VPC endpoints for secure communication
- Fine-grained IAM policies
- Input validation and sanitization

### Monitoring
- Comprehensive logging and monitoring
- Security Hub integration
- GuardDuty threat detection
- CloudTrail audit logging

### Compliance
- Follows AWS security best practices
- Implements defense in depth
- Regular security scanning
- Automated compliance checks

## Scaling

### Horizontal Scaling
- ECS service auto-scaling
- Lambda concurrency limits
- API Gateway throttling
- DynamoDB auto-scaling

### Vertical Scaling
- ECS task CPU/memory
- Lambda memory allocation
- OpenSearch instance types
- RDS instance sizes

## Maintenance

### Regular Tasks
1. Update dependencies
2. Review security findings
3. Monitor costs
4. Update documentation
5. Test disaster recovery

### Backup and Recovery
- DynamoDB point-in-time recovery
- S3 versioning and lifecycle policies
- ECS task definition backups
- Lambda function code backups

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review AWS documentation
3. Check GitHub issues
4. Contact the development team
