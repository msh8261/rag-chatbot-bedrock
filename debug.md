# RAG Chatbot Deployment Debug Guide

This document contains all the issues encountered during the RAG chatbot deployment and their solutions, including AWS CLI workarounds.

## Table of Contents

1. [Environment Setup Issues](#environment-setup-issues)
2. [Terraform Configuration Issues](#terraform-configuration-issues)
3. [AWS Service Issues](#aws-service-issues)
4. [Deployment Script Issues](#deployment-script-issues)
5. [API Gateway Issues](#api-gateway-issues)
6. [Lambda Function Issues](#lambda-function-issues)
7. [ECS and Docker Issues](#ecs-and-docker-issues)
8. [Monitoring and Logging Issues](#monitoring-and-logging-issues)
9. [Security and Permissions Issues](#security-and-permissions-issues)
10. [Troubleshooting Commands](#troubleshooting-commands)

## Environment Setup Issues

### Issue 1: `chmod` not recognized on Windows

**Problem**: The `chmod` command is not available in Windows PowerShell.

**Error Message**:
```
chmod: command not found
```

**Solution**:
- Use Git Bash or WSL instead of PowerShell
- Or run: `bash scripts/deploy.sh` in PowerShell
- Modified `deploy.sh` to use full Windows paths for Python and Terraform executables

### Issue 2: Python 3 not found in PATH

**Problem**: Python 3 executable not found in system PATH.

**Error Message**:
```
Python 3 is required but not installed. Aborting.
```

**Solution**:
- Modified `deploy.sh` to use full Windows path: `/c/Users/mohsen/AppData/Local/Programs/Python/Python311/python.exe`
- Added fallback to `python3` if full path not available

### Issue 3: Terraform not found in PATH

**Problem**: Terraform executable not found in system PATH.

**Error Message**:
```
Terraform is required but not installed. Aborting.
```

**Solution**:
- Modified `deploy.sh` to check multiple locations:
  - `terraform` in PATH
  - `/c/Users/mohsen/AppData/Local/Programs/Terraform/terraform.exe`
  - `./terraform.exe` in current directory
- Added `TERRAFORM_CMD` variable to store the correct path

## Terraform Configuration Issues

### Issue 4: Duplicate data sources

**Problem**: Duplicate `data "aws_region" "current" {}` blocks.

**Error Message**:
```
Error: Duplicate data "aws_region" configuration
```

**Solution**:
- Removed duplicate `data "aws_region" "current" {}` from `infrastructure/modules/monitoring/outputs.tf`

### Issue 5: Duplicate output definitions

**Problem**: Duplicate `output "domain_id"` definitions.

**Error Message**:
```
Error: Duplicate output definition "domain_id"
```

**Solution**:
- Removed duplicate `output "domain_id"` from `infrastructure/modules/opensearch/outputs.tf`

### Issue 6: Missing required arguments

**Problem**: Various modules missing required arguments.

**Error Messages**:
```
Error: Missing required argument
Error: Missing required argument "kms_key_id"
Error: Missing required argument "lambda_role_arn"
Error: Missing required argument "api_gateway_name"
```

**Solution**:
- Added missing variables to module calls in `infrastructure/terraform/main.tf`
- Added missing outputs to module output files

### Issue 7: Invalid attribute combinations

**Problem**: S3 lifecycle configuration missing required `filter` block.

**Error Message**:
```
Warning: Invalid Attribute Combination
```

**Solution**:
- Added `filter { prefix = "" }` to S3 lifecycle rules in `infrastructure/modules/s3/main.tf`

### Issue 8: Unsupported arguments

**Problem**: Various resources using unsupported arguments.

**Error Messages**:
```
Error: Unsupported argument "tags" in aws_lambda_layer_version
Error: Unsupported argument "master_instance_type" in cluster_config
Error: Unsupported argument "kms_key_id" in server_side_encryption
```

**Solution**:
- Removed unsupported arguments from resource configurations
- Updated resource configurations to match AWS provider requirements

## AWS Service Issues

### Issue 9: KMS Key not found

**Problem**: KMS key ID not found for CloudWatch log groups.

**Error Message**:
```
The specified KMS Key Id could not be found
```

**Solution**:
- Removed `kms_key_id` from all `aws_cloudwatch_log_group` resources
- Used default encryption for log groups

### Issue 10: VPC Endpoint Service not found

**Problem**: OpenSearch VPC endpoint service not available.

**Error Message**:
```
The Vpc Endpoint Service 'com.amazonaws.ap-southeast-1.es' does not exist
```

**Solution**:
- Commented out OpenSearch VPC endpoint in `infrastructure/modules/vpc/main.tf`
- OpenSearch requires AWS subscription for VPC endpoints

### Issue 11: Security services require subscription

**Problem**: Security Hub, GuardDuty, Inspector2 require AWS subscription.

**Error Message**:
```
The AWS Access Key Id needs a subscription for the service
```

**Solution**:
- Commented out security services in `infrastructure/modules/monitoring/main.tf`
- Removed related outputs from `infrastructure/modules/monitoring/outputs.tf`

### Issue 12: OpenSearch availability zone count

**Problem**: OpenSearch requires 2 or 3 availability zones.

**Error Message**:
```
expected cluster_config.0.zone_awareness_config.0.availability_zone_count to be one of [2 3], got 1
```

**Solution**:
- Changed `availability_zone_count` to `2` in `infrastructure/modules/opensearch/main.tf`

## Deployment Script Issues

### Issue 13: Python path issues on Windows

**Problem**: Python executable not found in expected locations.

**Error Message**:
```
ln: failed to create symbolic link '/usr/bin/python3': Permission denied
```

**Solution**:
- Modified `deploy.sh` to use full Windows paths for Python
- Added fallback logic for different Python installations

### Issue 14: Terraform command detection

**Problem**: Terraform command not found in PATH.

**Error Message**:
```
Terraform is required but not installed. Aborting.
```

**Solution**:
- Enhanced `check_prerequisites()` function to check multiple locations
- Added `TERRAFORM_CMD` variable to store the correct path

### Issue 15: ECR login issues

**Problem**: Docker not logged in to ECR.

**Error Message**:
```
Error: Cannot perform an interactive login from a non TTY device
```

**Solution**:
- Added ECR login step in `build_application()` function
- Used `aws ecr get-login-password` with `docker login`

## API Gateway Issues

### Issue 16: 403 Forbidden error

**Problem**: API Gateway returning 403 Forbidden.

**Error Message**:
```
403 Forbidden
```

**Solution**:
- Removed explicit Deny statement from API Gateway policy
- Added Allow statement for all principals
- Added lifecycle rule to ignore deployment_id changes

### Issue 17: CORS issues

**Problem**: CORS headers not properly configured.

**Error Message**:
```
Access to fetch at 'API_URL' from origin 'http://localhost:8501' has been blocked by CORS policy
```

**Solution**:
- Added proper CORS headers to Lambda response
- Configured API Gateway CORS settings

### Issue 18: API Gateway deployment issues

**Problem**: API Gateway deployment not updating.

**Error Message**:
```
API Gateway deployment not reflecting changes
```

**Solution**:
- Added triggers to force deployment when policy changes
- Added lifecycle rules to handle deployment updates

## Lambda Function Issues

### Issue 19: Lambda function not found

**Problem**: Lambda function not found when testing.

**Error Message**:
```
Function not found: arn:aws:lambda:ap-southeast-1:ACCOUNT:function:rag-chatbot-prod-rag-chatbot
```

**Solution**:
- Created simplified Lambda function for debugging
- Updated Terraform to use simplified function
- Added proper error handling and logging

### Issue 20: Lambda permissions issues

**Problem**: Lambda function missing required permissions.

**Error Message**:
```
AccessDeniedException: User is not authorized to perform: lambda:InvokeFunction
```

**Solution**:
- Added proper IAM permissions for Lambda execution
- Added API Gateway execution permissions
- Added CloudWatch logs permissions

### Issue 21: Lambda environment variables

**Problem**: Lambda function missing environment variables.

**Error Message**:
```
Environment variable not found
```

**Solution**:
- Added environment variables to Lambda function configuration
- Used Terraform variables for production
- Added `.env` file support for local development

## ECS and Docker Issues

### Issue 22: ECS task definition issues

**Problem**: ECS task definition not properly configured.

**Error Message**:
```
Invalid task definition
```

**Solution**:
- Updated container definition to use ECR image
- Added proper environment variables
- Configured logging and networking

### Issue 23: Docker image build issues

**Problem**: Docker image not building properly.

**Error Message**:
```
Docker build failed
```

**Solution**:
- Created proper Dockerfile for Streamlit application
- Added ECR login step
- Added image tagging and pushing

### Issue 24: ECR repository issues

**Problem**: ECR repository not accessible.

**Error Message**:
```
Repository not found
```

**Solution**:
- Created ECR repository in Terraform
- Added repository policy for access
- Added proper IAM permissions

## Monitoring and Logging Issues

### Issue 25: CloudWatch dashboard issues

**Problem**: CloudWatch dashboard not displaying properly.

**Error Message**:
```
Dashboard creation failed
```

**Solution**:
- Removed unsupported attributes from dashboard configuration
- Added proper widget configurations
- Fixed metric and dimension references

### Issue 26: CloudWatch alarms issues

**Problem**: CloudWatch alarms not creating properly.

**Error Message**:
```
Alarm creation failed
```

**Solution**:
- Fixed metric names and namespaces
- Added proper threshold configurations
- Added proper alarm actions

## Security and Permissions Issues

### Issue 27: IAM role issues

**Problem**: IAM roles not properly configured.

**Error Message**:
```
Invalid role name
```

**Solution**:
- Fixed IAM role names to use proper format
- Added proper trust relationships
- Added required permissions

### Issue 28: WAF configuration issues

**Problem**: WAF rules not properly configured.

**Error Message**:
```
Invalid WAF rule configuration
```

**Solution**:
- Added proper text transformation blocks
- Fixed rule priorities
- Added proper scope configurations

### Issue 29: API Gateway Stage Already Exists

**Problem**: When redeploying infrastructure, API Gateway stage creation fails because the stage already exists.

**Error Message**:
```
Error: creating API Gateway Stage (prod): operation error API Gateway: CreateStage, https response error StatusCode: 409, RequestID: cba0ac80-670b-4ee4-ba71-3d8d28ca0a78, ConflictException: Stage already exists
```

**Root Cause**: Duplicate API Gateway stage resources being created with the same stage name.

**Solution**:
1. **Remove duplicate stage resources** in `infrastructure/modules/api-gateway/main.tf`:
   ```terraform
   # Remove the duplicate aws_api_gateway_stage.waf resource
   # Keep only the main stage resource
   ```

2. **Add lifecycle rules** to handle stage creation gracefully:
   ```terraform
   resource "aws_api_gateway_stage" "main" {
     # ... other configuration ...
     
     lifecycle {
       ignore_changes = [deployment_id]
       create_before_destroy = true
     }
   }
   ```

3. **Consolidate WAF association** in the main stage:
   ```terraform
   resource "aws_api_gateway_stage" "main" {
     # ... other configuration ...
     web_acl_arn = var.enable_waf ? var.waf_web_acl_arn : null
   }
   ```

**AWS CLI Workaround**:
```bash
# Check existing stages
aws apigateway get-stages --rest-api-id <api-id> --region ap-southeast-1

# Import existing stage into Terraform state
terraform import module.api_gateway.aws_api_gateway_stage.main <api-id>/<stage-name>

# Or delete the existing stage manually
aws apigateway delete-stage --rest-api-id <api-id> --stage-name prod

# Or update the existing stage
aws apigateway update-stage --rest-api-id <api-id> --stage-name prod --patch-ops op=replace,path=/deploymentId,value=<new-deployment-id>
```

### Issue 30: Hardcoded Values in Terraform Configuration

**Problem**: The main.tf file contained hardcoded values making it difficult to customize deployments for different environments.

**Root Cause**: Values like VPC CIDR blocks, subnet configurations, and resource settings were hardcoded in the main.tf file.

**Solution**:
1. **Added comprehensive variables** to `infrastructure/terraform/variables.tf`:
   ```terraform
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
   ```

2. **Updated main.tf** to use variables instead of hardcoded values:
   ```terraform
   # Before (hardcoded)
   vpc_cidr = "10.0.0.0/16"
   
   # After (using variables)
   vpc_cidr = var.vpc_cidr
   ```

3. **Created terraform.tfvars** with all configuration values:
   ```hcl
   project_name = "rag-chatbot"
   environment  = "prod"
   aws_region   = "ap-southeast-1"
   vpc_cidr = "10.0.0.0/16"
   # ... other configurations
   ```

4. **Created terraform.tfvars.example** as a template for users.

**Benefits**:
- Easy environment-specific deployments
- No more hardcoded values
- Better maintainability
- Clear configuration documentation

## Troubleshooting Commands

### AWS CLI Commands

#### Check AWS credentials
```bash
aws sts get-caller-identity
```

#### List Lambda functions
```bash
aws lambda list-functions --region ap-southeast-1
```

#### Test Lambda function
```bash
aws lambda invoke --function-name rag-chatbot-prod-rag-chatbot --payload '{"message":"hello","session_id":"test"}' response.json
```

#### Check API Gateway
```bash
aws apigateway get-rest-apis --region ap-southeast-1
```

#### Check ECS services
```bash
aws ecs list-services --cluster rag-chatbot-prod-cluster --region ap-southeast-1
```

#### Check ECR repositories
```bash
aws ecr describe-repositories --region ap-southeast-1
```

#### Check CloudWatch logs
```bash
aws logs describe-log-groups --region ap-southeast-1
```

#### Check DynamoDB tables
```bash
aws dynamodb list-tables --region ap-southeast-1
```

#### Check S3 buckets
```bash
aws s3 ls
```

### Terraform Commands

#### Initialize Terraform
```bash
cd infrastructure/terraform
terraform init
```

#### Plan Terraform
```bash
terraform plan
```

#### Apply Terraform
```bash
terraform apply -auto-approve
```

#### Destroy Terraform
```bash
terraform destroy -auto-approve
```

#### Show Terraform outputs
```bash
terraform output
```

### Docker Commands

#### Build Docker image
```bash
docker build -t rag-chatbot-frontend:latest .
```

#### Tag Docker image
```bash
docker tag rag-chatbot-frontend:latest ACCOUNT.dkr.ecr.ap-southeast-1.amazonaws.com/rag-chatbot-prod-frontend:latest
```

#### Push Docker image
```bash
docker push ACCOUNT.dkr.ecr.ap-southeast-1.amazonaws.com/rag-chatbot-prod-frontend:latest
```

#### Login to ECR
```bash
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin ACCOUNT.dkr.ecr.ap-southeast-1.amazonaws.com
```

### Debugging Commands

#### Check application logs
```bash
aws logs tail /aws/lambda/rag-chatbot-prod-rag-chatbot --follow --region ap-southeast-1
```

#### Check ECS task logs
```bash
aws logs tail /ecs/rag-chatbot-prod-frontend --follow --region ap-southeast-1
```

#### Check API Gateway logs
```bash
aws logs tail /aws/apigateway/rag-chatbot-prod-api --follow --region ap-southeast-1
```

#### Test API endpoint
```bash
curl -X POST "https://API_ID.execute-api.ap-southeast-1.amazonaws.com/prod/chat" \
  -H "Content-Type: application/json" \
  -d '{"message":"hello","session_id":"test"}'
```

## Common Solutions

### 1. Environment Variables
- Use Terraform variables for production
- Use `.env` files for local development
- Generate `.env` from Terraform outputs

### 2. Python Path Issues
- Use full Windows paths for Python executables
- Add fallback logic for different installations
- Use `python3` as fallback

### 3. Terraform Issues
- Always run `terraform init` before other commands
- Use `terraform plan` to check for issues
- Use `terraform apply -auto-approve` for automated deployment

### 4. AWS Service Issues
- Check AWS credentials and permissions
- Verify service availability in region
- Check for subscription requirements

### 5. Docker Issues
- Login to ECR before pushing images
- Use proper image tags
- Check Docker daemon is running

### 6. API Gateway Issues
- Check CORS configuration
- Verify API Gateway policy
- Force deployment after changes

### 7. Lambda Issues
- Check IAM permissions
- Verify environment variables
- Check CloudWatch logs for errors

### 8. ECS Issues
- Check task definition
- Verify container image
- Check service configuration

## Prevention Tips

1. **Always test locally first** before deploying to AWS
2. **Use `terraform plan`** to check for issues before applying
3. **Check AWS service limits** and quotas
4. **Monitor CloudWatch logs** for errors
5. **Use proper error handling** in code
6. **Test API endpoints** after deployment
7. **Verify all environment variables** are set correctly
8. **Check IAM permissions** for all services
9. **Use proper logging** for debugging
10. **Keep Terraform state** in sync with actual resources

## Emergency Recovery

### If deployment fails completely:
1. Run `./scripts/destroy.sh` to clean up
2. Check AWS console for any remaining resources
3. Manually delete any orphaned resources
4. Run `./scripts/deploy.sh` again

### If specific service fails:
1. Check CloudWatch logs for the service
2. Verify IAM permissions
3. Check service configuration
4. Restart the service if possible

### If API is not responding:
1. Check API Gateway configuration
2. Verify Lambda function is working
3. Check CORS settings
4. Test with curl or Postman

This debug guide should help you troubleshoot any issues that arise during the RAG chatbot deployment process.
