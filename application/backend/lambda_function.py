"""
RAG Chatbot Lambda Function
Copyright (c) 2025 RAG Chatbot Project
Licensed under the MIT License
"""

import json
import boto3
import os
import logging
from datetime import datetime
from typing import Dict, Any, List
import uuid
import re

# Load .env file for local development (if exists)
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass  # dotenv not available, environment variables set by Terraform

# Environment variables are set by Terraform in production
# For local development, use: python scripts/get-api-url.py

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
bedrock_runtime = boto3.client('bedrock-runtime')
dynamodb = boto3.resource('dynamodb')
s3_client = boto3.client('s3')
opensearch_client = boto3.client('opensearchserverless')

# Environment variables (set by Terraform in production, .env for local development)
DYNAMODB_TABLE_NAME = os.environ.get('DYNAMODB_TABLE_NAME')
OPENSEARCH_ENDPOINT = os.environ.get('OPENSEARCH_ENDPOINT')
S3_BUCKET_NAME = os.environ.get('S3_BUCKET_NAME')
BEDROCK_MODEL_ID = os.environ.get('BEDROCK_MODEL_ID', 'anthropic.claude-3-sonnet-20240229-v1:0')

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Main Lambda handler for RAG chatbot
    """
    try:
        # Parse the request
        if 'body' in event:
            body = json.loads(event['body'])
        else:
            body = event
            
        user_message = body.get('message', '')
        session_id = body.get('session_id', str(uuid.uuid4()))
        user_id = body.get('user_id', 'anonymous')
        
        # Input validation and sanitization
        if not user_message or len(user_message.strip()) == 0:
            return create_response(400, {
                'error': 'Message cannot be empty',
                'session_id': session_id
            })
        
        # Sanitize input
        user_message = sanitize_input(user_message)
        
        # Retrieve chat history
        chat_history = get_chat_history(session_id)
        
        # Retrieve relevant context from knowledge base
        context = retrieve_context(user_message)
        
        # Generate response using Bedrock
        response = generate_response(user_message, context, chat_history)
        
        # Save conversation to DynamoDB
        save_conversation(session_id, user_id, user_message, response)
        
        return create_response(200, {
            'response': response,
            'session_id': session_id,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Error in lambda_handler: {str(e)}")
        return create_response(500, {
            'error': 'Internal server error',
            'session_id': session_id if 'session_id' in locals() else None
        })

def sanitize_input(text: str) -> str:
    """
    Sanitize user input to prevent injection attacks
    """
    # Remove potentially dangerous characters
    dangerous_chars = ['<', '>', '"', "'", '&', '\x00', '\r', '\n']
    for char in dangerous_chars:
        text = text.replace(char, '')
    
    # Remove potential prompt injection patterns
    injection_patterns = [
        r'ignore\s+previous\s+instructions',
        r'system\s+prompt',
        r'you\s+are\s+now',
        r'forget\s+everything',
        r'new\s+instructions',
        r'override\s+system'
    ]
    
    for pattern in injection_patterns:
        text = re.sub(pattern, '', text, flags=re.IGNORECASE)
    
    # Limit length
    text = text[:1000]
    
    return text.strip()

def get_chat_history(session_id: str) -> List[Dict[str, str]]:
    """
    Retrieve chat history for the session
    """
    try:
        table = dynamodb.Table(DYNAMODB_TABLE_NAME)
        
        response = table.query(
            KeyConditionExpression='session_id = :session_id',
            ExpressionAttributeValues={':session_id': session_id},
            ScanIndexForward=False,
            Limit=10  # Last 10 messages
        )
        
        history = []
        for item in response['Items']:
            history.append({
                'role': item.get('role', 'user'),
                'content': item.get('content', '')
            })
        
        return history
        
    except Exception as e:
        logger.error(f"Error retrieving chat history: {str(e)}")
        return []

def retrieve_context(query: str) -> str:
    """
    Retrieve relevant context from knowledge base using OpenSearch
    """
    try:
        # This is a simplified version - in production, you'd use OpenSearch
        # For now, we'll return a placeholder
        return "Relevant context from knowledge base would be retrieved here."
        
    except Exception as e:
        logger.error(f"Error retrieving context: {str(e)}")
        return ""

def generate_response(user_message: str, context: str, chat_history: List[Dict[str, str]]) -> str:
    """
    Generate response using Amazon Bedrock
    """
    try:
        # Prepare the prompt
        prompt = prepare_prompt(user_message, context, chat_history)
        
        # Call Bedrock
        response = bedrock_runtime.invoke_model(
            modelId=BEDROCK_MODEL_ID,
            body=json.dumps({
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": 1000,
                "messages": [
                    {
                        "role": "user",
                        "content": prompt
                    }
                ]
            })
        )
        
        # Parse response
        response_body = json.loads(response['body'].read())
        return response_body['content'][0]['text']
        
    except Exception as e:
        logger.error(f"Error generating response: {str(e)}")
        return "I apologize, but I'm having trouble generating a response right now. Please try again later."

def prepare_prompt(user_message: str, context: str, chat_history: List[Dict[str, str]]) -> str:
    """
    Prepare the prompt for the LLM
    """
    system_prompt = """You are a helpful AI assistant. Use the provided context to answer questions accurately and helpfully. 
    If you don't know something, say so. Be concise but informative."""
    
    # Build conversation history
    history_text = ""
    for msg in reversed(chat_history[-5:]):  # Last 5 messages
        role = "Human" if msg['role'] == 'user' else "Assistant"
        history_text += f"{role}: {msg['content']}\n"
    
    prompt = f"""System: {system_prompt}

Context: {context}

{history_text}Human: {user_message}

Assistant:"""
    
    return prompt

def save_conversation(session_id: str, user_id: str, user_message: str, assistant_response: str):
    """
    Save conversation to DynamoDB
    """
    try:
        table = dynamodb.Table(DYNAMODB_TABLE_NAME)
        timestamp = datetime.utcnow().isoformat()
        
        # Save user message
        table.put_item(Item={
            'session_id': session_id,
            'timestamp': f"{timestamp}#user",
            'user_id': user_id,
            'role': 'user',
            'content': user_message,
            'ttl': int(datetime.utcnow().timestamp()) + 86400 * 30  # 30 days
        })
        
        # Save assistant response
        table.put_item(Item={
            'session_id': session_id,
            'timestamp': f"{timestamp}#assistant",
            'user_id': user_id,
            'role': 'assistant',
            'content': assistant_response,
            'ttl': int(datetime.utcnow().timestamp()) + 86400 * 30  # 30 days
        })
        
    except Exception as e:
        logger.error(f"Error saving conversation: {str(e)}")

def create_response(status_code: int, body: Dict[str, Any]) -> Dict[str, Any]:
    """
    Create a standardized response
    """
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        'body': json.dumps(body)
    }
