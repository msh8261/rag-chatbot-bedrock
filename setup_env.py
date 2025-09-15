#!/usr/bin/env python3
"""
Environment Setup Script for RAG Chatbot
This script helps you create a .env file from the example template.
"""

import os
import shutil
from pathlib import Path

def main():
    """Main function to set up environment file for local development"""
    print("🔧 RAG Chatbot Local Development Environment Setup")
    print("=" * 60)
    print("ℹ️  Note: This is for LOCAL DEVELOPMENT only.")
    print("ℹ️  Production uses GitHub Secrets and AWS environment variables.")
    print("=" * 60)
    
    # Check if .env already exists
    env_file = Path(".env")
    example_file = Path("env.local.example")
    
    if env_file.exists():
        response = input("⚠️  .env file already exists. Do you want to overwrite it? (y/N): ")
        if response.lower() != 'y':
            print("❌ Setup cancelled.")
            return
    
    if not example_file.exists():
        print("❌ Error: env.example file not found!")
        print("Please make sure env.example exists in the current directory.")
        return
    
    try:
        # Copy example to .env
        shutil.copy2(example_file, env_file)
        print("✅ Created .env file from env.example")
        
        # Get user input for key variables
        print("\n📝 Let's configure the application variables:")
        print("(Press Enter to keep default values)")
        
        # API Gateway Configuration
        print("\n🚪 API Gateway Configuration:")
        print("You need the API Gateway URL from your deployed infrastructure")
        api_gateway_url = input("API Gateway URL [https://your-api-gateway-url.execute-api.region.amazonaws.com/prod]: ").strip() or "https://your-api-gateway-url.execute-api.region.amazonaws.com/prod"
        
        # Development Configuration
        print("\n🔧 Development Configuration:")
        environment = input("Environment [dev]: ").strip() or "dev"
        debug = input("Enable debug mode? (y/N): ").strip().lower() == 'y'
        
        # Update the .env file with user input
        update_env_file(env_file, {
            'API_GATEWAY_URL': api_gateway_url,
            'ENVIRONMENT': environment,
            'DEBUG': 'true' if debug else 'false'
        })
        
        print("\n✅ Environment setup completed!")
        print("\n📋 Next steps:")
        print("1. Review and update the .env file with your actual values")
        print("2. Run the application: python application/frontend/app.py")
        print("3. Deploy infrastructure: ./scripts/deploy.sh")
        
    except Exception as e:
        print(f"❌ Error during setup: {str(e)}")

def update_env_file(env_file, updates):
    """Update specific variables in the .env file"""
    try:
        with open(env_file, 'r') as f:
            lines = f.readlines()
        
        # Update specific lines
        for i, line in enumerate(lines):
            for key, value in updates.items():
                if line.startswith(f"{key}="):
                    lines[i] = f"{key}={value}\n"
                    break
        
        with open(env_file, 'w') as f:
            f.writelines(lines)
            
    except Exception as e:
        print(f"⚠️  Warning: Could not update .env file: {str(e)}")

if __name__ == "__main__":
    main()
