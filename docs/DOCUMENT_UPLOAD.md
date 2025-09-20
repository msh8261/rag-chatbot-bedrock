# Document Upload Functionality

This document describes the document upload functionality implemented for the RAG chatbot application.

## Overview

The document upload feature allows users to upload documents through the Streamlit frontend, which are then stored in S3 and processed for use in the RAG (Retrieval-Augmented Generation) system.

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Streamlit     │    │   API Gateway   │    │   Lambda        │
│   Frontend      │◄──►│   /upload       │◄──►│   Function      │
│   (File Upload) │    │   Endpoint      │    │   (Handler)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       ▼
         │                       │              ┌─────────────────┐
         │                       │              │   S3 Bucket     │
         │                       │              │   (Documents)   │
         │                       │              └─────────────────┘
         │                       │                       │
         │                       │                       ▼
         │                       │              ┌─────────────────┐
         │                       │              │   DynamoDB      │
         │                       │              │   (Metadata)    │
         │                       │              └─────────────────┘
```

## Features

### Frontend (Streamlit)
- **File Upload Widget**: Supports drag-and-drop file selection
- **File Validation**: Client-side validation for file type and size
- **Progress Feedback**: Real-time upload status and error messages
- **Supported Formats**: PDF, TXT, DOCX, DOC, MD, RTF
- **File Size Limit**: 10MB maximum per file

### Backend (Lambda)
- **API Endpoint**: `/upload` POST endpoint
- **File Processing**: Base64 decoding and validation
- **S3 Storage**: Secure file storage with KMS encryption
- **Metadata Storage**: Document information stored in DynamoDB
- **Error Handling**: Comprehensive error handling and logging

### Infrastructure
- **API Gateway**: New `/upload` endpoint with CORS support
- **S3 Bucket**: Dedicated documents bucket with encryption
- **IAM Permissions**: Lambda role with S3 and DynamoDB access
- **Security**: VPC isolation, WAF protection, encryption at rest

## API Endpoints

### Upload Document
- **Method**: POST
- **Endpoint**: `/upload`
- **Content-Type**: application/json

#### Request Body
```json
{
  "filename": "document.pdf",
  "file_content": "base64_encoded_content",
  "mime_type": "application/pdf",
  "session_id": "user-session-123",
  "user_id": "user-456"
}
```

#### Response (Success)
```json
{
  "success": true,
  "document_id": "uuid-document-id",
  "filename": "document.pdf",
  "size": 1024000,
  "s3_key": "documents/user-456/uuid-document-id/document.pdf",
  "timestamp": "2025-01-27T10:30:00Z"
}
```

#### Response (Error)
```json
{
  "error": "File type not supported",
  "status_code": 400
}
```

## File Validation

### Client-Side Validation (Frontend)
- **File Extension**: Must be one of: .pdf, .txt, .docx, .doc, .md, .rtf
- **File Size**: Maximum 10MB
- **MIME Type**: Validated against allowed types

### Server-Side Validation (Lambda)
- **File Extension**: Double-checked against allowed extensions
- **MIME Type**: Validated against allowed MIME types
- **File Size**: Re-validated after base64 decoding
- **Content Validation**: Basic content integrity checks

## Supported File Types

| Extension | MIME Type | Description |
|-----------|-----------|-------------|
| .pdf | application/pdf | PDF documents |
| .txt | text/plain | Plain text files |
| .docx | application/vnd.openxmlformats-officedocument.wordprocessingml.document | Word documents (new format) |
| .doc | application/msword | Word documents (legacy format) |
| .md | text/markdown | Markdown files |
| .rtf | application/rtf, text/rtf | Rich Text Format |

## Storage Structure

### S3 Bucket Organization
```
s3://bucket-name/
└── documents/
    └── {user_id}/
        └── {document_id}/
            └── {filename}
```

### DynamoDB Metadata
```json
{
  "session_id": "user-session-123",
  "timestamp": "2025-01-27T10:30:00Z#document",
  "user_id": "user-456",
  "document_id": "uuid-document-id",
  "filename": "document.pdf",
  "s3_key": "documents/user-456/uuid-document-id/document.pdf",
  "file_size": 1024000,
  "status": "uploaded",
  "ttl": 1737991800
}
```

## Security Features

### Data Protection
- **Encryption at Rest**: S3 objects encrypted with KMS
- **Encryption in Transit**: HTTPS/TLS for all communications
- **Access Control**: IAM roles with least privilege access
- **VPC Isolation**: Lambda function runs in private subnets

### Input Validation
- **File Type Validation**: Strict MIME type and extension checking
- **Size Limits**: 10MB maximum file size
- **Content Sanitization**: Base64 decoding with error handling
- **SQL Injection Prevention**: Parameterized queries for DynamoDB

### Network Security
- **WAF Protection**: Web Application Firewall rules
- **CORS Configuration**: Proper cross-origin resource sharing
- **Rate Limiting**: API Gateway throttling and quotas

## Usage Instructions

### For Users
1. Open the RAG chatbot application
2. Navigate to the "Document Upload" section
3. Click "Choose a document to upload"
4. Select a supported file (PDF, TXT, DOCX, DOC, MD, RTF)
5. Click "Upload Document" to process the file
6. Wait for confirmation of successful upload

### For Developers
1. Deploy the updated infrastructure with `bash scripts/deploy.sh`
2. Test the upload functionality with `python scripts/test-upload.py`
3. Monitor CloudWatch logs for any issues
4. Check S3 bucket for uploaded files
5. Verify DynamoDB metadata entries

## Testing

### Manual Testing
```bash
# Set API Gateway URL
export API_GATEWAY_URL="https://your-api-id.execute-api.region.amazonaws.com/prod"

# Run test script
python scripts/test-upload.py
```

### Test Coverage
- ✅ File upload via API
- ✅ File validation (type, size)
- ✅ S3 storage verification
- ✅ DynamoDB metadata storage
- ✅ Error handling
- ✅ CORS configuration
- ✅ Authentication and authorization

## Monitoring and Logging

### CloudWatch Logs
- **Lambda Logs**: `/aws/lambda/rag-chatbot-prod-lambda`
- **API Gateway Logs**: `/aws/apigateway/rag-chatbot-prod`
- **S3 Access Logs**: Available in S3 bucket

### Key Metrics
- Upload success rate
- File processing time
- Error rates by type
- Storage usage
- API Gateway latency

### Alarms
- High error rate (>5%)
- Long processing time (>30s)
- Storage quota exceeded
- API Gateway 4xx/5xx errors

## Troubleshooting

### Common Issues

#### Upload Fails with "File type not supported"
- **Cause**: File extension or MIME type not in allowed list
- **Solution**: Use supported file types (.pdf, .txt, .docx, .doc, .md, .rtf)

#### Upload Fails with "File size exceeds limit"
- **Cause**: File larger than 10MB
- **Solution**: Compress or split large files

#### Upload Fails with "Connection error"
- **Cause**: Network issues or API Gateway problems
- **Solution**: Check API Gateway status and network connectivity

#### Upload Succeeds but File Not in S3
- **Cause**: IAM permissions or S3 bucket issues
- **Solution**: Check Lambda execution role permissions and S3 bucket configuration

### Debug Steps
1. Check CloudWatch logs for Lambda function
2. Verify API Gateway logs
3. Test with smaller files
4. Check IAM permissions
5. Verify S3 bucket configuration

## Future Enhancements

### Planned Features
- **Batch Upload**: Multiple file upload support
- **File Processing**: Automatic text extraction and chunking
- **Progress Tracking**: Real-time upload progress
- **File Management**: View and delete uploaded documents
- **Search Integration**: Automatic indexing for RAG system

### Performance Optimizations
- **Chunked Upload**: Large file upload in chunks
- **Compression**: Automatic file compression
- **Caching**: CDN integration for faster access
- **Async Processing**: Background document processing

## Dependencies

### Frontend
- `streamlit`: Web application framework
- `requests`: HTTP client for API calls
- `base64`: File encoding/decoding
- `mimetypes`: MIME type detection

### Backend
- `boto3`: AWS SDK for Python
- `botocore`: AWS core functionality
- `json`: JSON processing
- `uuid`: Unique identifier generation

### Infrastructure
- **API Gateway**: REST API management
- **Lambda**: Serverless compute
- **S3**: Object storage
- **DynamoDB**: NoSQL database
- **IAM**: Identity and access management
- **KMS**: Key management service

## License

This document is part of the RAG Chatbot project and is licensed under the MIT License.
