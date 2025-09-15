#!/bin/bash

# RAG Chatbot Deployment Script
# This script automates the deployment of the RAG Chatbot infrastructure and application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TERRAFORM_DIR="infrastructure/terraform"
APPLICATION_DIR="application"
ENVIRONMENT=${1:-prod}
AWS_REGION=${2:-us-east-1}

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if required tools are installed
    command -v terraform >/dev/null 2>&1 || { log_error "Terraform is required but not installed. Aborting."; exit 1; }
    command -v aws >/dev/null 2>&1 || { log_error "AWS CLI is required but not installed. Aborting."; exit 1; }
    command -v docker >/dev/null 2>&1 || { log_error "Docker is required but not installed. Aborting."; exit 1; }
    command -v python3 >/dev/null 2>&1 || { log_error "Python 3 is required but not installed. Aborting."; exit 1; }
    
    # Check AWS credentials
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        log_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

deploy_infrastructure() {
    log_info "Deploying infrastructure..."
    
    cd $TERRAFORM_DIR
    
    # Initialize Terraform
    log_info "Initializing Terraform..."
    terraform init
    
    # Plan deployment
    log_info "Planning Terraform deployment..."
    terraform plan -var="environment=$ENVIRONMENT" -var="aws_region=$AWS_REGION" -out=tfplan
    
    # Apply deployment
    log_info "Applying Terraform deployment..."
    terraform apply tfplan
    
    # Get outputs
    log_info "Getting Terraform outputs..."
    terraform output -json > outputs.json
    
    log_success "Infrastructure deployed successfully"
    cd - > /dev/null
}

build_application() {
    log_info "Building application components..."
    
    # Build frontend Docker image
    log_info "Building frontend Docker image..."
    cd $APPLICATION_DIR/frontend
    docker build -t rag-chatbot-frontend:latest .
    cd - > /dev/null
    
    # Package Lambda function
    log_info "Packaging Lambda function..."
    cd $APPLICATION_DIR/backend
    pip install -r requirements.txt -t .
    zip -r lambda-deployment.zip .
    cd - > /dev/null
    
    log_success "Application components built successfully"
}

deploy_application() {
    log_info "Deploying application..."
    
    # Get infrastructure outputs
    if [ ! -f "$TERRAFORM_DIR/outputs.json" ]; then
        log_error "Infrastructure outputs not found. Please deploy infrastructure first."
        exit 1
    fi
    
    # Extract values from Terraform outputs
    API_GATEWAY_URL=$(jq -r '.api_gateway_url.value' $TERRAFORM_DIR/outputs.json)
    LAMBDA_FUNCTION_NAME=$(jq -r '.lambda_function_name.value' $TERRAFORM_DIR/outputs.json)
    ECS_CLUSTER_NAME=$(jq -r '.ecs_cluster_name.value' $TERRAFORM_DIR/outputs.json)
    ECS_SERVICE_NAME=$(jq -r '.ecs_service_name.value' $TERRAFORM_DIR/outputs.json)
    
    # Update Lambda function
    log_info "Updating Lambda function..."
    aws lambda update-function-code \
        --function-name $LAMBDA_FUNCTION_NAME \
        --zip-file fileb://$APPLICATION_DIR/backend/lambda-deployment.zip
    
    # Update ECS service
    log_info "Updating ECS service..."
    aws ecs update-service \
        --cluster $ECS_CLUSTER_NAME \
        --service $ECS_SERVICE_NAME \
        --force-new-deployment
    
    # Wait for deployment to complete
    log_info "Waiting for ECS deployment to complete..."
    aws ecs wait services-stable \
        --cluster $ECS_CLUSTER_NAME \
        --services $ECS_SERVICE_NAME
    
    log_success "Application deployed successfully"
}

test_deployment() {
    log_info "Testing deployment..."
    
    # Get API Gateway URL
    API_GATEWAY_URL=$(jq -r '.api_gateway_url.value' $TERRAFORM_DIR/outputs.json)
    
    # Test API endpoint
    log_info "Testing API endpoint..."
    response=$(curl -s -X POST $API_GATEWAY_URL/chat \
        -H "Content-Type: application/json" \
        -d '{"message": "Hello, test message", "session_id": "test-session", "user_id": "test-user"}' \
        --max-time 30)
    
    if echo "$response" | jq -e '.response' > /dev/null 2>&1; then
        log_success "API endpoint test passed"
    else
        log_error "API endpoint test failed"
        log_error "Response: $response"
        exit 1
    fi
    
    # Test ECS service health
    log_info "Testing ECS service health..."
    ALB_DNS=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(LoadBalancerName, `rag-chatbot-'$ENVIRONMENT'`)].DNSName' --output text)
    
    if curl -f http://$ALB_DNS/_stcore/health --max-time 30 > /dev/null 2>&1; then
        log_success "ECS service health check passed"
    else
        log_warning "ECS service health check failed (this might be expected if the service is still starting)"
    fi
}

cleanup() {
    log_info "Cleaning up temporary files..."
    rm -f $APPLICATION_DIR/backend/lambda-deployment.zip
    rm -f $TERRAFORM_DIR/tfplan
    log_success "Cleanup completed"
}

show_deployment_info() {
    log_info "Deployment completed successfully!"
    echo
    echo "=== Deployment Information ==="
    echo "Environment: $ENVIRONMENT"
    echo "AWS Region: $AWS_REGION"
    echo "API Gateway URL: $(jq -r '.api_gateway_url.value' $TERRAFORM_DIR/outputs.json)"
    echo "CloudFront URL: $(jq -r '.application_url.value' $TERRAFORM_DIR/outputs.json)"
    echo "Dashboard URL: $(jq -r '.monitoring_dashboard_url.value' $TERRAFORM_DIR/outputs.json)"
    echo
    echo "=== Next Steps ==="
    echo "1. Upload documents to S3 bucket for knowledge base"
    echo "2. Configure Bedrock models and knowledge base"
    echo "3. Test the application thoroughly"
    echo "4. Set up monitoring and alerting"
    echo "5. Review security settings and compliance"
    echo
}

# Main execution
main() {
    log_info "Starting RAG Chatbot deployment..."
    log_info "Environment: $ENVIRONMENT"
    log_info "AWS Region: $AWS_REGION"
    echo
    
    check_prerequisites
    deploy_infrastructure
    build_application
    deploy_application
    test_deployment
    cleanup
    show_deployment_info
    
    log_success "Deployment completed successfully!"
}

# Handle script arguments
case "${1:-}" in
    "infrastructure")
        check_prerequisites
        deploy_infrastructure
        ;;
    "application")
        check_prerequisites
        build_application
        deploy_application
        ;;
    "test")
        test_deployment
        ;;
    "cleanup")
        cleanup
        ;;
    *)
        main
        ;;
esac
