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
import base64
import mimetypes
from botocore.exceptions import ClientError

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
        # Log the incoming event for debugging
        logger.info(f"Received event: {json.dumps(event)}")
        
        # Get HTTP method and path
        http_method = event.get('httpMethod', 'POST')
        path = event.get('path', '/')
        
        # Handle API Gateway proxy integration
        if 'requestContext' in event:
            if 'http' in event['requestContext']:
                # API Gateway v2 event structure
                http_method = event['requestContext']['http']['method']
                path = event['requestContext']['http']['path']
            elif 'httpMethod' in event['requestContext']:
                # API Gateway v1 event structure
                http_method = event['requestContext']['httpMethod']
                path = event['requestContext']['path']
        
        logger.info(f"HTTP Method: {http_method}, Path: {path}")
        
        # Route to appropriate handler - handle both direct and API Gateway paths
        if http_method == 'POST':
            if path in ['/chat', '/prod/chat', '/']:
                logger.info("Routing to chat handler")
                return handle_chat_request(event)
            elif path in ['/upload', '/prod/upload']:
                logger.info("Routing to upload handler")
                return handle_upload_request(event)
        
        if http_method == 'OPTIONS':
            logger.info("Handling OPTIONS request")
            return create_response(200, {'message': 'OK'})
        
        logger.warning(f"No handler found for {http_method} {path}")
        return create_response(404, {'error': 'Not found'})
            
    except Exception as e:
        logger.error(f"Error in lambda_handler: {str(e)}")
        return create_response(500, {
            'error': 'Internal server error'
        })

def handle_chat_request(event: Dict[str, Any]) -> Dict[str, Any]:
    """
    Handle chat requests
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
        logger.error(f"Error in handle_chat_request: {str(e)}")
        return create_response(500, {
            'error': 'Internal server error'
        })

def handle_upload_request(event: Dict[str, Any]) -> Dict[str, Any]:
    """
    Handle file upload requests
    """
    try:
        # Parse the request
        if 'body' in event:
            body = json.loads(event['body'])
        else:
            body = event
            
        filename = body.get('filename', '')
        file_content = body.get('file_content', '')
        mime_type = body.get('mime_type', 'application/octet-stream')
        session_id = body.get('session_id', str(uuid.uuid4()))
        user_id = body.get('user_id', 'anonymous')
        
        # Validate input
        if not filename or not file_content:
            return create_response(400, {
                'error': 'Filename and file content are required'
            })
        
        # Validate file type
        if not validate_file_type(filename, mime_type):
            return create_response(400, {
                'error': 'File type not supported'
            })
        
        # Decode base64 content
        try:
            file_bytes = base64.b64decode(file_content)
        except Exception as e:
            logger.error(f"Error decoding base64: {str(e)}")
            return create_response(400, {
                'error': 'Invalid file content encoding'
            })
        
        # Validate file size (max 10MB)
        if len(file_bytes) > 10 * 1024 * 1024:
            return create_response(400, {
                'error': 'File size exceeds 10MB limit'
            })
        
        # Generate unique document ID
        document_id = str(uuid.uuid4())
        
        # Upload to S3
        s3_key = f"documents/{user_id}/{document_id}/{filename}"
        upload_result = upload_to_s3(file_bytes, s3_key, mime_type)
        
        if not upload_result:
            return create_response(500, {
                'error': 'Failed to upload file to storage'
            })
        
        # Save document metadata to DynamoDB
        save_document_metadata(document_id, filename, s3_key, user_id, session_id, len(file_bytes))
        
        return create_response(200, {
            'success': True,
            'document_id': document_id,
            'filename': filename,
            'size': len(file_bytes),
            's3_key': s3_key,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Error in handle_upload_request: {str(e)}")
        return create_response(500, {
            'error': 'Internal server error'
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
        if not OPENSEARCH_ENDPOINT:
            logger.warning("OpenSearch endpoint not configured, using placeholder context")
            return "Relevant context from knowledge base would be retrieved here."
        
        # Initialize OpenSearch client
        from opensearchpy import OpenSearch, RequestsHttpConnection
        from aws_requests_auth import AWSRequestsAuth
        
        # Create AWS authentication
        auth = AWSRequestsAuth(
            aws_access_key=os.environ.get('AWS_ACCESS_KEY_ID'),
            aws_secret_access_key=os.environ.get('AWS_SECRET_ACCESS_KEY'),
            aws_token=os.environ.get('AWS_SESSION_TOKEN'),
            aws_host=OPENSEARCH_ENDPOINT.replace('https://', ''),
            aws_region=os.environ.get('AWS_REGION', 'ap-southeast-1'),
            aws_service='es'
        )
        
        # Create OpenSearch client
        client = OpenSearch(
            hosts=[{'host': OPENSEARCH_ENDPOINT.replace('https://', ''), 'port': 443}],
            http_auth=auth,
            use_ssl=True,
            verify_certs=True,
            connection_class=RequestsHttpConnection
        )
        
        # Search for relevant documents
        search_body = {
            "query": {
                "multi_match": {
                    "query": query,
                    "fields": ["content", "title", "filename"],
                    "type": "best_fields",
                    "fuzziness": "AUTO"
                }
            },
            "size": 5,
            "_source": ["content", "title", "filename", "s3_key"]
        }
        
        response = client.search(
            index="documents",
            body=search_body
        )
        
        # Extract relevant context
        context_parts = []
        for hit in response['hits']['hits']:
            source = hit['_source']
            content = source.get('content', '')
            title = source.get('title', source.get('filename', 'Unknown'))
            
            # Truncate content if too long
            if len(content) > 500:
                content = content[:500] + "..."
            
            context_parts.append(f"Document: {title}\nContent: {content}")
        
        if context_parts:
            return "\n\n".join(context_parts)
        else:
            return "No relevant documents found in the knowledge base."
        
    except Exception as e:
        logger.error(f"Error retrieving context from OpenSearch: {str(e)}")
        return "Error retrieving context from knowledge base."

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

def validate_file_type(filename: str, mime_type: str) -> bool:
    """
    Validate file type based on extension and MIME type
    """
    allowed_extensions = ['.pdf', '.txt', '.docx', '.doc', '.md', '.rtf']
    allowed_mime_types = [
        'application/pdf',
        'text/plain',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/msword',
        'text/markdown',
        'application/rtf',
        'text/rtf'
    ]
    
    # Check file extension
    file_extension = os.path.splitext(filename)[1].lower()
    if file_extension not in allowed_extensions:
        return False
    
    # Check MIME type
    if mime_type not in allowed_mime_types:
        return False
    
    return True

def upload_to_s3(file_bytes: bytes, s3_key: str, mime_type: str) -> bool:
    """
    Upload file to S3 bucket
    """
    try:
        s3_client.put_object(
            Bucket=S3_BUCKET_NAME,
            Key=s3_key,
            Body=file_bytes,
            ContentType=mime_type,
            ServerSideEncryption='aws:kms'
        )
        logger.info(f"Successfully uploaded {s3_key} to S3")
        return True
    except ClientError as e:
        logger.error(f"Error uploading to S3: {str(e)}")
        return False
    except Exception as e:
        logger.error(f"Unexpected error uploading to S3: {str(e)}")
        return False

def save_document_metadata(document_id: str, filename: str, s3_key: str, user_id: str, session_id: str, file_size: int):
    """
    Save document metadata to DynamoDB
    """
    try:
        table = dynamodb.Table(DYNAMODB_TABLE_NAME)
        timestamp = datetime.utcnow().isoformat()
        
        table.put_item(Item={
            'session_id': session_id,
            'timestamp': f"{timestamp}#document",
            'user_id': user_id,
            'document_id': document_id,
            'filename': filename,
            's3_key': s3_key,
            'file_size': file_size,
            'status': 'uploaded',
            'ttl': int(datetime.utcnow().timestamp()) + 86400 * 365  # 1 year
        })
        
        logger.info(f"Saved document metadata for {document_id}")
        
        # Process document for OpenSearch indexing
        process_document_for_search(document_id, filename, s3_key, user_id)
        
    except Exception as e:
        logger.error(f"Error saving document metadata: {str(e)}")

def process_document_for_search(document_id: str, filename: str, s3_key: str, user_id: str):
    """
    Process document and index it in OpenSearch for search
    """
    try:
        if not OPENSEARCH_ENDPOINT:
            logger.warning("OpenSearch endpoint not configured, skipping document indexing")
            return
        
        # Download document from S3
        response = s3_client.get_object(Bucket=S3_BUCKET_NAME, Key=s3_key)
        file_content = response['Body'].read()
        
        # Extract text content based on file type
        content = extract_text_from_file(file_content, filename)
        
        if not content:
            logger.warning(f"Could not extract text from {filename}")
            return
        
        # Index document in OpenSearch
        index_document_in_opensearch(document_id, filename, content, s3_key, user_id)
        
    except Exception as e:
        logger.error(f"Error processing document for search: {str(e)}")

def extract_text_from_file(file_content: bytes, filename: str) -> str:
    """
    Extract text content from various file types
    """
    try:
        file_extension = os.path.splitext(filename)[1].lower()
        
        if file_extension == '.txt':
            return file_content.decode('utf-8')
        elif file_extension == '.md':
            return file_content.decode('utf-8')
        elif file_extension == '.pdf':
            # For PDF, we'd need PyPDF2 or similar library
            # For now, return a placeholder
            return f"PDF content from {filename} (text extraction not implemented)"
        elif file_extension in ['.docx', '.doc']:
            # For Word documents, we'd need python-docx library
            # For now, return a placeholder
            return f"Word document content from {filename} (text extraction not implemented)"
        else:
            return f"Content from {filename} (text extraction not implemented for this file type)"
            
    except Exception as e:
        logger.error(f"Error extracting text from {filename}: {str(e)}")
        return ""

def index_document_in_opensearch(document_id: str, filename: str, content: str, s3_key: str, user_id: str):
    """
    Index document in OpenSearch for search
    """
    try:
        from opensearchpy import OpenSearch, RequestsHttpConnection
        from aws_requests_auth import AWSRequestsAuth
        
        # Create AWS authentication
        auth = AWSRequestsAuth(
            aws_access_key=os.environ.get('AWS_ACCESS_KEY_ID'),
            aws_secret_access_key=os.environ.get('AWS_SECRET_ACCESS_KEY'),
            aws_token=os.environ.get('AWS_SESSION_TOKEN'),
            aws_host=OPENSEARCH_ENDPOINT.replace('https://', ''),
            aws_region=os.environ.get('AWS_REGION', 'ap-southeast-1'),
            aws_service='es'
        )
        
        # Create OpenSearch client
        client = OpenSearch(
            hosts=[{'host': OPENSEARCH_ENDPOINT.replace('https://', ''), 'port': 443}],
            http_auth=auth,
            use_ssl=True,
            verify_certs=True,
            connection_class=RequestsHttpConnection
        )
        
        # Create index if it doesn't exist
        if not client.indices.exists(index="documents"):
            index_mapping = {
                "mappings": {
                    "properties": {
                        "document_id": {"type": "keyword"},
                        "filename": {"type": "text"},
                        "title": {"type": "text"},
                        "content": {"type": "text"},
                        "s3_key": {"type": "keyword"},
                        "user_id": {"type": "keyword"},
                        "uploaded_at": {"type": "date"},
                        "file_type": {"type": "keyword"}
                    }
                }
            }
            client.indices.create(index="documents", body=index_mapping)
        
        # Index the document
        doc_body = {
            "document_id": document_id,
            "filename": filename,
            "title": filename,
            "content": content,
            "s3_key": s3_key,
            "user_id": user_id,
            "uploaded_at": datetime.utcnow().isoformat(),
            "file_type": os.path.splitext(filename)[1].lower()
        }
        
        client.index(
            index="documents",
            id=document_id,
            body=doc_body
        )
        
        logger.info(f"Successfully indexed document {document_id} in OpenSearch")
        
    except Exception as e:
        logger.error(f"Error indexing document in OpenSearch: {str(e)}")

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
