"""
RAG Chatbot Simplified Lambda Function
Copyright (c) 2025 RAG Chatbot Project
Licensed under the MIT License
"""

import json
import logging
from datetime import datetime
from typing import Dict, Any

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Simplified Lambda handler for testing
    """
    try:
        # Parse the request
        if 'body' in event:
            body = json.loads(event['body'])
        else:
            body = event
            
        user_message = body.get('message', '')
        session_id = body.get('session_id', 'test123')
        
        # Simple response without Bedrock
        if "capital city of france" in user_message.lower():
            response = "The capital city of France is Paris."
        elif "hello" in user_message.lower():
            response = "Hello! How can I help you today?"
        else:
            response = f"I received your message: '{user_message}'. This is a test response from the Lambda function."
        
        return create_response(200, {
            'response': response,
            'session_id': session_id,
            'timestamp': datetime.utcnow().isoformat(),
            'status': 'success'
        })
        
    except Exception as e:
        logger.error(f"Error in lambda_handler: {str(e)}")
        return create_response(500, {
            'error': f'Internal server error: {str(e)}',
            'session_id': session_id if 'session_id' in locals() else None
        })

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
