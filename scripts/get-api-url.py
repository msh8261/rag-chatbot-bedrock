#!/usr/bin/env python3
"""
Get API Gateway URL from Terraform outputs for local development
Copyright (c) 2025 RAG Chatbot Project
Licensed under the MIT License
"""

import json
import os
import sys
from pathlib import Path

def get_terraform_outputs():
    """Get all Terraform outputs"""
    terraform_dir = Path("infrastructure/terraform")
    outputs_file = terraform_dir / "outputs.json"
    
    if not outputs_file.exists():
        print("❌ Terraform outputs not found. Please run 'terraform apply' first.")
        print("   Or run: ./scripts/deploy.sh")
        return None
    
    try:
        with open(outputs_file, 'r') as f:
            outputs = json.load(f)
        
        return outputs
            
    except Exception as e:
        print(f"❌ Error reading Terraform outputs: {e}")
        return None

def create_env_file(outputs):
    """Create .env file for local development"""
    api_url = outputs.get('api_gateway_url', {}).get('value', '')
    dynamodb_table = outputs.get('dynamodb_table_name', {}).get('value', '')
    opensearch_endpoint = outputs.get('opensearch_endpoint', {}).get('value', '')
    s3_bucket = outputs.get('s3_bucket_name', {}).get('value', '')
    
    env_content = f"""# Local Development Environment Variables
# Generated automatically from Terraform outputs

# Frontend Configuration
API_GATEWAY_URL={api_url}
ENVIRONMENT=dev
DEBUG=true
LOG_LEVEL=DEBUG

# Backend Configuration (for local Lambda testing)
DYNAMODB_TABLE_NAME={dynamodb_table}
OPENSEARCH_ENDPOINT={opensearch_endpoint}
S3_BUCKET_NAME={s3_bucket}
BEDROCK_MODEL_ID=anthropic.claude-3-sonnet-20240229-v1:0

# Streamlit Configuration
STREAMLIT_SERVER_PORT=8501
STREAMLIT_SERVER_ADDRESS=localhost
STREAMLIT_SERVER_HEADLESS=false
STREAMLIT_BROWSER_GATHER_USAGE_STATS=false
"""
    
    with open('.env', 'w') as f:
        f.write(env_content)
    
    print("✅ Created .env file for local development")
    print(f"   - API Gateway URL: {api_url}")
    print(f"   - DynamoDB Table: {dynamodb_table}")
    print(f"   - OpenSearch Endpoint: {opensearch_endpoint}")
    print(f"   - S3 Bucket: {s3_bucket}")

def main():
    """Main function"""
    print("🔍 Getting environment variables from Terraform outputs...")
    
    outputs = get_terraform_outputs()
    if outputs:
        create_env_file(outputs)
        print("\n🚀 Now you can run the applications locally:")
        print("   Frontend: cd application/frontend && streamlit run app.py")
        print("   Backend:  cd application/backend && python lambda_function.py")
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()
