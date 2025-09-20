# 🔒 Advanced Security Services Implementation Guide

This guide explains how to enable and configure the advanced security services for the RAG Chatbot architecture.

## 📋 Overview

The following security services have been implemented and are ready to be enabled:

1. **AWS Shield Advanced** - DDoS protection
2. **GuardDuty** - Threat detection
3. **Amazon Inspector** - Vulnerability assessment
4. **Security Hub** - Centralized security management
5. **Security Lake** - Centralized log analysis
6. **Bedrock Guardrails** - AI safety controls

## 🚀 Quick Start

### 1. Enable CloudFront (Already Done)
✅ CloudFront module has been enabled in `main.tf`

### 2. Enable Advanced Security Services

To enable all advanced security services, update your `terraform.tfvars`:

```hcl
# Advanced Security Services (require AWS subscriptions)
enable_shield_advanced = true
enable_guardduty = true
enable_inspector = true
enable_security_hub = true
enable_security_lake = true
```

### 3. Deploy the Infrastructure

```bash
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

## 🔧 Individual Service Configuration

### AWS Shield Advanced

**Purpose**: DDoS protection for API Gateway and CloudFront

**Configuration**:
```hcl
enable_shield_advanced = true
```

**Requirements**:
- AWS Shield Advanced subscription
- Additional costs apply

**Features**:
- DDoS protection
- Attack monitoring
- Response team access
- Custom protection rules

### GuardDuty

**Purpose**: Threat detection across AWS accounts

**Configuration**:
```hcl
enable_guardduty = true
enable_guardduty_s3_protection = true
enable_guardduty_kubernetes_protection = false
enable_guardduty_malware_protection = true
```

**Requirements**:
- GuardDuty subscription
- Additional costs apply

**Features**:
- Threat detection
- Malware protection
- S3 protection
- Kubernetes protection
- Findings aggregation

### Amazon Inspector

**Purpose**: Vulnerability assessment for compute resources

**Configuration**:
```hcl
enable_inspector = true
inspector_resource_types = ["EC2", "ECR", "LAMBDA"]
enable_inspector_ec2 = true
enable_inspector_ecr = true
enable_inspector_lambda = true
enable_inspector_auto_run = false
```

**Requirements**:
- Inspector subscription
- Additional costs apply

**Features**:
- EC2 vulnerability scanning
- ECR image scanning
- Lambda function scanning
- Custom assessment templates

### Security Hub

**Purpose**: Centralized security findings management

**Configuration**:
```hcl
enable_security_hub = true
enable_security_hub_default_standards = true
enable_security_hub_cis = true
enable_security_hub_pci = false
enable_security_hub_nist = true
enable_security_hub_aggregation = false
```

**Requirements**:
- Security Hub subscription
- Additional costs apply

**Features**:
- Centralized findings
- Compliance standards
- Custom insights
- Automated remediation

### Security Lake

**Purpose**: Centralized log analysis and security data lake

**Configuration**:
```hcl
enable_security_lake = true
```

**Requirements**:
- Security Lake subscription
- Additional costs apply

**Features**:
- Centralized log storage
- Custom log sources
- Data subscribers
- Advanced analytics

## 🛡️ Bedrock Guardrails

**Purpose**: AI safety controls for Bedrock models

**Status**: Ready to enable when Bedrock Knowledge Base is active

**Configuration**: Automatically enabled when Bedrock module is uncommented

**Features**:
- Content filtering
- Word policy controls
- Topic restrictions
- Prompt injection protection

## 💰 Cost Considerations

### Free Tier Services
- Basic WAF rules
- CloudWatch basic monitoring
- VPC endpoints (data transfer costs)

### Paid Services (Require Subscriptions)
- **AWS Shield Advanced**: $3,000/month + usage
- **GuardDuty**: $0.10 per GB analyzed
- **Amazon Inspector**: $0.15 per scan
- **Security Hub**: $0.10 per finding
- **Security Lake**: $0.50 per GB ingested

## 🔄 Enabling Services Step by Step

### Step 1: Enable Basic Security (Already Done)
✅ WAF protection
✅ VPC endpoints
✅ IAM roles and policies
✅ KMS encryption
✅ CloudWatch monitoring

### Step 2: Enable CloudFront (Already Done)
✅ CloudFront distribution
✅ WAF integration
✅ Security headers

### Step 3: Enable Advanced Services (Optional)
Choose which services to enable based on your security requirements:

```bash
# Enable all services
terraform apply -var="enable_shield_advanced=true" \
                -var="enable_guardduty=true" \
                -var="enable_inspector=true" \
                -var="enable_security_hub=true" \
                -var="enable_security_lake=true"

# Or enable individually
terraform apply -var="enable_guardduty=true"
```

### Step 4: Enable Bedrock Knowledge Base (When Ready)
Uncomment the Bedrock module in `main.tf` when OpenSearch subscription is available.

## 📊 Monitoring and Alerts

All security services include:
- CloudWatch alarms
- SNS notifications
- Custom dashboards
- Log aggregation

## 🔍 Verification

After enabling services, verify they're working:

1. **Shield**: Check CloudWatch metrics for DDoS events
2. **GuardDuty**: Review findings in GuardDuty console
3. **Inspector**: Check assessment results
4. **Security Hub**: Review aggregated findings
5. **Security Lake**: Verify log ingestion

## 🚨 Important Notes

1. **Subscriptions Required**: Most advanced services require AWS subscriptions
2. **Costs**: Additional costs apply for paid services
3. **Regional Availability**: Some services may not be available in all regions
4. **Dependencies**: Some services depend on others (e.g., Bedrock requires OpenSearch)

## 📞 Support

For issues with specific services:
- AWS Shield: AWS Support
- GuardDuty: AWS Support
- Inspector: AWS Support
- Security Hub: AWS Support
- Security Lake: AWS Support

## 🔗 Related Documentation

- [AWS Shield Advanced](https://docs.aws.amazon.com/waf/latest/developerguide/ddos-overview.html)
- [GuardDuty](https://docs.aws.amazon.com/guardduty/)
- [Amazon Inspector](https://docs.aws.amazon.com/inspector/)
- [Security Hub](https://docs.aws.amazon.com/securityhub/)
- [Security Lake](https://docs.aws.amazon.com/security-lake/)
