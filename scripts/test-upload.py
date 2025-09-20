#!/usr/bin/env python3
"""
Test script for document upload functionality
Copyright (c) 2025 RAG Chatbot Project
Licensed under the MIT License
"""

import requests
import json
import base64
import os
import sys
from pathlib import Path

def test_upload_endpoint(api_url, test_file_path):
    """
    Test the upload endpoint with a sample file
    """
    print(f"Testing upload endpoint: {api_url}/upload")
    print(f"Test file: {test_file_path}")
    
    # Check if test file exists
    if not os.path.exists(test_file_path):
        print(f"❌ Test file not found: {test_file_path}")
        return False
    
    # Read and encode file
    with open(test_file_path, 'rb') as f:
        file_content = base64.b64encode(f.read()).decode('utf-8')
    
    # Prepare request
    payload = {
        "filename": os.path.basename(test_file_path),
        "file_content": file_content,
        "mime_type": "text/plain",
        "session_id": "test-session-123",
        "user_id": "test-user"
    }
    
    try:
        # Send request
        response = requests.post(
            f"{api_url}/upload",
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                print("✅ Upload test passed!")
                print(f"Document ID: {result.get('document_id')}")
                print(f"S3 Key: {result.get('s3_key')}")
                return True
            else:
                print("❌ Upload failed - success flag not set")
                return False
        else:
            print(f"❌ Upload test failed with status {response.status_code}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {str(e)}")
        return False

def test_chat_endpoint(api_url):
    """
    Test the chat endpoint to ensure it still works
    """
    print(f"\nTesting chat endpoint: {api_url}/chat")
    
    payload = {
        "message": "Hello, this is a test message",
        "session_id": "test-session-123",
        "user_id": "test-user"
    }
    
    try:
        response = requests.post(
            f"{api_url}/chat",
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Chat test passed!")
            print(f"Response: {result.get('response', 'No response')[:100]}...")
            return True
        else:
            print(f"❌ Chat test failed with status {response.status_code}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Chat request failed: {str(e)}")
        return False

def create_test_file():
    """
    Create a test file for upload testing
    """
    test_content = """# Test Document

This is a test document for the RAG chatbot upload functionality.

## Features Tested
- File upload via API
- Base64 encoding/decoding
- S3 storage
- DynamoDB metadata storage

## Content
The quick brown fox jumps over the lazy dog. This is a sample text to test the document processing capabilities of the RAG chatbot system.

## Technical Details
- File format: Markdown
- Size: Small test file
- Purpose: API endpoint testing

This document should be successfully uploaded and stored in the S3 bucket with proper metadata in DynamoDB.
"""
    
    test_file_path = "test-document.md"
    with open(test_file_path, 'w', encoding='utf-8') as f:
        f.write(test_content)
    
    print(f"Created test file: {test_file_path}")
    return test_file_path

def main():
    """
    Main test function
    """
    print("🧪 RAG Chatbot Upload Functionality Test")
    print("=" * 50)
    
    # Get API URL from environment or use default
    api_url = os.environ.get('API_GATEWAY_URL')
    if not api_url:
        print("❌ API_GATEWAY_URL environment variable not set")
        print("Please set it to your API Gateway URL (e.g., https://your-api-id.execute-api.region.amazonaws.com/prod)")
        sys.exit(1)
    
    print(f"API URL: {api_url}")
    
    # Create test file
    test_file = create_test_file()
    
    try:
        # Test chat endpoint first
        chat_success = test_chat_endpoint(api_url)
        
        # Test upload endpoint
        upload_success = test_upload_endpoint(api_url, test_file)
        
        # Summary
        print("\n" + "=" * 50)
        print("📊 Test Results Summary")
        print("=" * 50)
        print(f"Chat Endpoint: {'✅ PASS' if chat_success else '❌ FAIL'}")
        print(f"Upload Endpoint: {'✅ PASS' if upload_success else '❌ FAIL'}")
        
        if chat_success and upload_success:
            print("\n🎉 All tests passed! Upload functionality is working correctly.")
            return 0
        else:
            print("\n❌ Some tests failed. Please check the error messages above.")
            return 1
            
    finally:
        # Clean up test file
        if os.path.exists(test_file):
            os.remove(test_file)
            print(f"\n🧹 Cleaned up test file: {test_file}")

if __name__ == "__main__":
    sys.exit(main())
