# Environment Variables Setup Guide

This guide explains how to set up environment variables for the RAG Chatbot project.

## 🎯 Different Use Cases

### 1. **GitHub Secrets** (CI/CD Pipeline) ✅ Already Configured
- Used during deployment in GitHub Actions
- Secure storage for production values
- Automatically injected during build/deploy
- **You already have this set up!**

### 2. **Local Development** (`.env` file)
- For developers working locally
- Testing and development environment
- Not committed to git (in `.gitignore`)

### 3. **Production Runtime** (AWS Environment Variables)
- Set in Lambda function configuration
- ECS task definitions
- Managed by Terraform/CloudFormation

## Quick Setup for Local Development

1. **For local development only:**
   ```bash
   cp env.local.example .env
   ```

2. **Edit the .env file with your local values:**
   ```bash
   nano .env  # or use your preferred editor
   ```

## Application Environment Variables

### Required for Local Development

| Variable | Description | Example |
|----------|-------------|---------|
| `API_GATEWAY_URL` | API Gateway endpoint URL for frontend | `https://abc123.execute-api.us-east-1.amazonaws.com/prod` |

### Optional Application Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ENVIRONMENT` | Environment identifier | `dev` |
| `DEBUG` | Enable debug mode | `true` |
| `LOG_LEVEL` | Logging level | `DEBUG` |
| `ENABLE_CHAT_HISTORY` | Enable chat history feature | `true` |
| `ENABLE_DOCUMENT_UPLOAD` | Enable document upload | `true` |
| `ENABLE_RATE_LIMITING` | Enable rate limiting | `false` |

### Streamlit Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `STREAMLIT_SERVER_PORT` | Port for Streamlit server | `8501` |
| `STREAMLIT_SERVER_ADDRESS` | Server address | `localhost` |
| `STREAMLIT_SERVER_HEADLESS` | Run in headless mode | `false` |

## Configuration Sections

The `.env` file is organized into sections:

- **AWS Configuration**: AWS credentials and region
- **Project Configuration**: Project name and environment
- **API Gateway**: API Gateway settings
- **Bedrock**: AI model configuration
- **Database**: DynamoDB settings
- **OpenSearch**: Search engine configuration
- **S3**: File storage settings
- **ECS**: Container service settings
- **Lambda**: Serverless function settings
- **VPC**: Network configuration
- **Security**: Security and compliance settings
- **Monitoring**: Logging and monitoring
- **Feature Flags**: Enable/disable features

## Getting Values

### From Terraform Outputs

After deploying infrastructure with Terraform, you can get the actual values:

```bash
cd infrastructure/terraform
terraform output -json > outputs.json
```

Then extract specific values:
```bash
# API Gateway URL
jq -r '.api_gateway_url.value' outputs.json

# DynamoDB table name
jq -r '.dynamodb_table_name.value' outputs.json

# S3 bucket name
jq -r '.s3_bucket_name.value' outputs.json
```

### From AWS Console

1. **API Gateway**: Go to API Gateway → Your API → Stages → prod
2. **DynamoDB**: Go to DynamoDB → Tables → Your table
3. **S3**: Go to S3 → Your bucket
4. **OpenSearch**: Go to OpenSearch → Domains → Your domain

## Security Best Practices

1. **Never commit .env files** to version control
2. **Use IAM roles** instead of access keys when possible
3. **Rotate credentials** regularly
4. **Use least privilege** principle for IAM permissions
5. **Enable MFA** for AWS accounts

## Development vs Production

### Development
```bash
ENVIRONMENT=dev
DEBUG=true
LOG_LEVEL=DEBUG
```

### Production
```bash
ENVIRONMENT=prod
DEBUG=false
LOG_LEVEL=INFO
ENABLE_MONITORING=true
ENABLE_WAF=true
```

## Troubleshooting

### Common Issues

1. **"ModuleNotFoundError: No module named 'dotenv'"**
   ```bash
   pip install python-dotenv
   ```

2. **Environment variables not loading**
   - Check if `.env` file exists in the correct directory
   - Verify file permissions
   - Check for syntax errors in `.env` file

3. **AWS credentials not working**
   - Verify AWS credentials are correct
   - Check AWS region matches your resources
   - Ensure IAM permissions are sufficient

### Validation

Test your environment setup:

```bash
# Test frontend
cd application/frontend
python -c "from dotenv import load_dotenv; load_dotenv(); import os; print('API_GATEWAY_URL:', os.getenv('API_GATEWAY_URL'))"

# Test backend
cd application/backend
python -c "from dotenv import load_dotenv; load_dotenv(); import os; print('DYNAMODB_TABLE_NAME:', os.getenv('DYNAMODB_TABLE_NAME'))"
```

## File Structure

```
project/
├── .env                    # Your environment variables (create this)
├── env.example            # Template with all variables
├── setup_env.py           # Setup script
├── ENV_SETUP.md          # This guide
└── application/
    ├── frontend/
    │   ├── app.py         # Loads .env automatically
    │   └── requirements.txt
    └── backend/
        ├── lambda_function.py  # Loads .env automatically
        └── requirements.txt
```

## Support

If you encounter issues:

1. Check this guide first
2. Review the error messages carefully
3. Verify all required variables are set
4. Check AWS credentials and permissions
5. Consult the main README.md for deployment instructions
