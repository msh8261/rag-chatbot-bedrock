# GitHub Actions Workflows

This directory contains GitHub Actions workflows for the RAG Chatbot project.

## Workflows

### 1. CI (`.github/workflows/ci.yml`)
- **Trigger**: Pull requests and pushes to main/develop branches
- **Purpose**: Run linting, testing, and Terraform validation
- **Features**:
  - Python code linting with flake8
  - Terraform format check and validation
  - Import testing for Python modules

### 2. Security Scan (`.github/workflows/security-scan.yml`)
- **Trigger**: Pull requests and pushes to main/develop branches
- **Purpose**: Comprehensive security scanning
- **Features**:
  - Bandit security scan for Python code
  - Safety check for Python dependencies
  - Semgrep static analysis
  - Checkov for Terraform security
  - Trivy container vulnerability scanning
  - AWS Security Hub and GuardDuty checks (if enabled)

### 3. Deploy (`.github/workflows/deploy.yml`)
- **Trigger**: Pushes to main branch and manual dispatch
- **Purpose**: Deploy infrastructure and application
- **Features**:
  - Terraform deployment
  - Docker image build and push to ECR
  - ECS service update
  - Deployment testing

## Required Secrets

Add these secrets to your GitHub repository:

1. **AWS_ACCESS_KEY_ID**: AWS access key for deployment
2. **AWS_SECRET_ACCESS_KEY**: AWS secret key for deployment

## Permissions

The workflows require the following permissions:
- `contents: read` - Read repository contents
- `security-events: write` - Upload security scan results
- `actions: read` - Read workflow information
- `id-token: write` - For AWS authentication (if using OIDC)

## Notes

- Security Hub checks are optional and will skip if subscription is not available
- Terraform state files are excluded from the repository
- All workflows use the latest stable versions of actions
- Container scanning includes both filesystem and dependency scanning
