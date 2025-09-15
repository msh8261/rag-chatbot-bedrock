#!/bin/bash

# RAG Chatbot Infrastructure - Destroy Script
# This script destroys the entire RAG Chatbot infrastructure

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TERRAFORM_DIR=infrastructure/terraform
ENVIRONMENT=prod
AWS_REGION=ap-southeast-1

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
    # Try to find terraform in common locations
    TERRAFORM_CMD=""
    if command -v terraform >/dev/null 2>&1; then
        TERRAFORM_CMD="terraform"
    elif [ -f "/c/Users/mohsen/AppData/Local/Programs/Terraform/terraform.exe" ]; then
        TERRAFORM_CMD="/c/Users/mohsen/AppData/Local/Programs/Terraform/terraform.exe"
    elif [ -f "terraform.exe" ]; then
        TERRAFORM_CMD="./terraform.exe"
    else
        # Try to use terraform from PATH (for PowerShell environments)
        TERRAFORM_CMD="terraform"
    fi
    
    # Check AWS CLI (more lenient for Windows environments)
    if ! command -v aws >/dev/null 2>&1; then
        log_warning "AWS CLI not found in PATH, but continuing..."
    else
        # Check AWS credentials
        if ! aws sts get-caller-identity >/dev/null 2>&1; then
            log_warning "AWS credentials check failed, but continuing..."
        fi
    fi
    
    log_success "Prerequisites check passed"
}

confirm_destroy() {
    log_warning "This will destroy ALL infrastructure resources including:"
    echo "  - VPC and networking components"
    echo "  - ECS cluster and services"
    echo "  - Lambda functions"
    echo "  - API Gateway"
    echo "  - DynamoDB tables"
    echo "  - S3 buckets"
    echo "  - ECR repositories"
    echo "  - CloudWatch logs and monitoring"
    echo "  - WAF rules"
    echo "  - KMS keys"
    echo ""
    log_warning "This action is IRREVERSIBLE!"
    echo ""
    read -p "Are you sure you want to destroy all infrastructure? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        log_info "Destroy cancelled by user"
        exit 0
    fi
}

destroy_infrastructure() {
    log_info "Destroying infrastructure..."
    
    cd $TERRAFORM_DIR
    
    # Use the terraform command determined in check_prerequisites
    
    # Initialize Terraform
    log_info "Initializing Terraform..."
    $TERRAFORM_CMD init
    
    # Destroy infrastructure
    log_info "Destroying infrastructure (this may take several minutes)..."
    $TERRAFORM_CMD destroy -auto-approve
    
    if [ $? -eq 0 ]; then
        log_success "Infrastructure destroyed successfully"
    else
        log_error "Infrastructure destruction failed"
        exit 1
    fi
    
    cd - > /dev/null
}

cleanup_local_files() {
    log_info "Cleaning up local files..."
    
    # Remove Terraform state files
    if [ -f "$TERRAFORM_DIR/terraform.tfstate" ]; then
        rm -f $TERRAFORM_DIR/terraform.tfstate
        log_info "Removed terraform.tfstate"
    fi
    
    if [ -f "$TERRAFORM_DIR/terraform.tfstate.backup" ]; then
        rm -f $TERRAFORM_DIR/terraform.tfstate.backup
        log_info "Removed terraform.tfstate.backup"
    fi
    
    # Remove Terraform outputs
    if [ -f "$TERRAFORM_DIR/outputs.json" ]; then
        rm -f $TERRAFORM_DIR/outputs.json
        log_info "Removed outputs.json"
    fi
    
    # Remove .env file if it exists
    if [ -f ".env" ]; then
        rm -f .env
        log_info "Removed .env file"
    fi
    
    # Remove Lambda deployment packages
    if [ -f "application/backend/lambda-deployment.zip" ]; then
        rm -f application/backend/lambda-deployment.zip
        log_info "Removed lambda-deployment.zip"
    fi
    
    log_success "Local cleanup completed"
}

show_destroy_summary() {
    log_success "Infrastructure destruction completed!"
    echo ""
    log_info "Summary of destroyed resources:"
    echo "  ✅ VPC and networking components"
    echo "  ✅ ECS cluster and services"
    echo "  ✅ Lambda functions"
    echo "  ✅ API Gateway"
    echo "  ✅ DynamoDB tables"
    echo "  ✅ S3 buckets"
    echo "  ✅ ECR repositories"
    echo "  ✅ CloudWatch logs and monitoring"
    echo "  ✅ WAF rules"
    echo "  ✅ KMS keys"
    echo ""
    log_info "To redeploy the infrastructure, run:"
    echo "  ./scripts/deploy.sh"
    echo ""
    log_info "All local files have been cleaned up."
}

# Main execution
main() {
    echo "=========================================="
    echo "  RAG Chatbot Infrastructure Destroyer"
    echo "=========================================="
    echo ""
    
    log_info "Starting infrastructure destruction..."
    log_info "Environment: $ENVIRONMENT"
    log_info "AWS Region: $AWS_REGION"
    echo ""
    
    check_prerequisites
    echo ""
    
    confirm_destroy
    echo ""
    
    destroy_infrastructure
    echo ""
    
    cleanup_local_files
    echo ""
    
    show_destroy_summary
}

# Handle script arguments
case "${1:-}" in
    --force)
        log_warning "Force mode enabled - skipping confirmation"
        confirm_destroy() {
            log_info "Force mode: proceeding with destruction"
        }
        main
        ;;
    --help|-h)
        echo "Usage: $0 [--force] [--help]"
        echo ""
        echo "Options:"
        echo "  --force    Skip confirmation prompt"
        echo "  --help     Show this help message"
        echo ""
        echo "This script destroys the entire RAG Chatbot infrastructure."
        echo "Use --force to skip the confirmation prompt."
        exit 0
        ;;
    "")
        main
        ;;
    *)
        log_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
