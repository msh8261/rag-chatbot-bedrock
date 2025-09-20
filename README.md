# Hardening the RAG chatbot architecture powered by Amazon Bedrock: Blueprint for secure design and anti-pattern mitigation

https://aws.amazon.com/blogs/security/hardening-the-rag-chatbot-architecture-powered-by-amazon-bedrock-blueprint-for-secure-design-and-anti-pattern-migration/


A production-ready Retrieval Augmented Generation (RAG) chatbot application built with AWS services, featuring a Streamlit frontend and serverless backend architecture.

## 🚀 Features

- **Frontend**: Modern Streamlit web application with real-time chat interface
- **Backend**: Serverless AWS Lambda function with Bedrock integration
- **Infrastructure**: Fully automated deployment using Terraform
- **Security**: WAF protection, VPC isolation, encryption at rest and in transit
- **Monitoring**: CloudWatch dashboards and alarms
- **Scalability**: Auto-scaling ECS containers and serverless Lambda functions

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Streamlit     │    │   API Gateway   │    │   Lambda        │
│   Frontend      │◄──►│   (REST API)    │◄──►│   Function      │
│   (ECS)         │    │                 │    │   (Backend)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       ▼
         │                       │              ┌─────────────────┐
         │                       │              │   AWS Bedrock   │
         │                       │              │   (AI/ML)       │
         │                       │              └─────────────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌─────────────────┐
│   Application   │    │   DynamoDB      │
│   Load Balancer │    │   (Chat History)│
└─────────────────┘    └─────────────────┘
```

## 🛠️ Tech Stack

### Frontend
- **Streamlit**: Web application framework
- **Python 3.11**: Programming language
- **Docker**: Containerization

### Backend
- **AWS Lambda**: Serverless compute
- **AWS Bedrock**: AI/ML services
- **Python 3.11**: Programming language

### Infrastructure
- **Terraform**: Infrastructure as Code
- **AWS ECS**: Container orchestration
- **AWS API Gateway**: API management
- **AWS DynamoDB**: NoSQL database
- **AWS S3**: Object storage
- **AWS VPC**: Network isolation
- **AWS WAF**: Web application firewall
- **AWS CloudWatch**: Monitoring and logging

## 📋 Prerequisites

- **AWS CLI** configured with appropriate permissions
- **Terraform** (v1.0+)
- **Docker** (for local development)
- **Python 3.11+**
- **Git**

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone <repository-url>
cd RAG-CHATBOT-BEDROCK
```

### 2. Deploy Infrastructure
```bash
# Deploy everything with one command
bash scripts/deploy.sh

# Or deploy step by step
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

### 3. Access the Application
After deployment, you'll get:
- **Frontend URL**: Application Load Balancer endpoint
- **API Gateway URL**: REST API endpoint

### 4. Clean Up
```bash
# Destroy all infrastructure
bash scripts/destroy.sh

# Or with force (skip confirmation)
bash scripts/destroy.sh --force
```

## 📁 Project Structure

```
RAG-CHATBOT-BEDROCK/
├── application/
│   ├── frontend/           # Streamlit web application
│   │   ├── app.py         # Main application file
│   │   ├── requirements.txt
│   │   └── Dockerfile
│   └── backend/            # Lambda function
│       ├── lambda_function.py
│       ├── lambda_function_simple.py
│       └── requirements.txt
├── infrastructure/
│   ├── terraform/          # Main Terraform configuration
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── modules/            # Terraform modules
│       ├── api-gateway/
│       ├── ecs/
│       ├── lambda/
│       ├── vpc/
│       └── ...
├── scripts/
│   ├── deploy.sh           # Automated deployment script
│   ├── destroy.sh          # Infrastructure cleanup script
│   └── get-api-url.py      # Environment setup script
├── .github/
│   └── workflows/          # CI/CD pipelines
├── LICENSE
└── README.md
```

## 🔧 Configuration

### Environment Variables

The application supports both production (Terraform-managed) and local development environments:

#### Production (Automatic)
- Environment variables are set by Terraform in ECS task definitions
- No manual configuration required

#### Local Development
```bash
# Generate .env file from Terraform outputs
python scripts/get-api-url.py

# Or manually create .env file
cat > .env << EOF
API_GATEWAY_URL=https://your-api-gateway-url.amazonaws.com/prod
ENVIRONMENT=dev
DEBUG=true
EOF
```

### AWS Services Configuration

The infrastructure automatically configures:
- **VPC**: Private and public subnets across multiple AZs
- **Security Groups**: Restrictive firewall rules
- **WAF**: Protection against common attacks
- **Encryption**: KMS keys for data at rest
- **Monitoring**: CloudWatch dashboards and alarms

## 🚀 Deployment Options

### 1. Automated Deployment (Recommended)
```bash
bash scripts/deploy.sh
```

### 2. Manual Terraform Deployment
```bash
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

### 3. CI/CD Pipeline
The project includes GitHub Actions workflows for automated deployment:
- **Deploy on push to main branch**
- **Destroy on pull request close**
- **Security scanning**

## 🔍 Monitoring

### CloudWatch Dashboards
- **Application Metrics**: Request rates, error rates, latency
- **Infrastructure Metrics**: CPU, memory, network usage
- **Security Metrics**: WAF blocked requests, failed authentications

### Alarms
- **High Error Rate**: API Gateway 4xx/5xx errors
- **High Latency**: Lambda function duration
- **Resource Utilization**: ECS service health

## 🔒 Security Features

- **Network Isolation**: VPC with private subnets
- **WAF Protection**: Rate limiting, SQL injection, XSS protection
- **Encryption**: Data encrypted at rest and in transit
- **IAM Roles**: Least privilege access
- **VPC Endpoints**: Secure AWS service communication

## 🧪 Testing

### Local Testing
```bash
# Test frontend locally
cd application/frontend
streamlit run app.py

# Test backend locally
cd application/backend
python lambda_function.py
```

### API Testing
```bash
# Test API Gateway
curl -X POST https://your-api-gateway-url.amazonaws.com/prod/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, how are you?", "session_id": "test123"}'
```

## 📊 Performance

- **Auto-scaling**: ECS services scale based on CPU/memory usage
- **Caching**: API Gateway response caching
- **CDN**: CloudFront distribution (optional)
- **Database**: DynamoDB on-demand scaling

## 🛠️ Development

### Adding New Features
1. Update the appropriate module in `infrastructure/modules/`
2. Test locally with `python scripts/get-api-url.py`
3. Deploy with `bash scripts/deploy.sh`
4. Verify functionality

### Customizing Infrastructure
1. Modify Terraform files in `infrastructure/terraform/`
2. Update variables in `variables.tf`
3. Run `terraform plan` to preview changes
4. Apply with `terraform apply`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check this README and inline code comments
- **Issues**: Create a GitHub issue for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions

## 🙏 Acknowledgments

- **AWS Bedrock** for AI/ML capabilities
- **Streamlit** for the web framework
- **Terraform** for infrastructure automation
- **Open source community** for various libraries and tools

---

**Built with ❤️ using AWS services and modern DevOps practices**