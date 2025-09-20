# Quick Start Script for RAG Chatbot Frontend
# Simple PowerShell script to quickly launch the frontend

Write-Host "🤖 RAG Chatbot Frontend - Quick Start" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "application/frontend/app.py")) {
    Write-Host "❌ Error: Please run this script from the project root directory" -ForegroundColor Red
    Write-Host "   Current directory: $(Get-Location)" -ForegroundColor Yellow
    Write-Host "   Expected: RAG chatbot project root" -ForegroundColor Yellow
    exit 1
}

# Get API URL from user
Write-Host "🔗 Enter your API Gateway URL:" -ForegroundColor Yellow
Write-Host "   Example: https://abc123def4.execute-api.ap-southeast-1.amazonaws.com/prod" -ForegroundColor Gray
$ApiUrl = Read-Host "API URL"

if ($ApiUrl -eq "") {
    Write-Host "❌ API URL is required" -ForegroundColor Red
    exit 1
}

# Set environment variables
$env:API_GATEWAY_URL = $ApiUrl
$env:ENVIRONMENT = "prod"

Write-Host ""
Write-Host "🚀 Starting frontend..." -ForegroundColor Green
Write-Host "   API URL: $ApiUrl" -ForegroundColor White
Write-Host "   Port: 8501" -ForegroundColor White
Write-Host "   Browser will open automatically" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

# Change to frontend directory and run
Push-Location "application/frontend"
try {
    streamlit run app.py --server.port 8501 --server.address localhost
} finally {
    Pop-Location
}
