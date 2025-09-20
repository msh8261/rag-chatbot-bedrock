@echo off
echo.
echo 🤖 RAG Chatbot Frontend - Demo Mode
echo ====================================
echo.

REM Check if we're in the right directory
if not exist "application\frontend\app.py" (
    echo ❌ Error: Please run this script from the project root directory
    echo    Current directory: %CD%
    pause
    exit /b 1
)

REM Set demo environment variables
set API_GATEWAY_URL=https://demo-api.execute-api.region.amazonaws.com/prod
set ENVIRONMENT=demo

echo 🔧 Setting up demo environment...
echo    API URL: %API_GATEWAY_URL%
echo    Environment: %ENVIRONMENT%
echo.

REM Create demo .env file
echo # RAG Chatbot Demo Environment Configuration > application\frontend\.env
echo API_GATEWAY_URL=%API_GATEWAY_URL% >> application\frontend\.env
echo ENVIRONMENT=%ENVIRONMENT% >> application\frontend\.env

echo ✅ Demo environment configured
echo.

echo 🚀 Starting RAG Chatbot Frontend in Demo Mode...
echo    The application will open in your default browser
echo    Note: This is demo mode - features are simulated
echo    Press Ctrl+C to stop the server
echo.

REM Change to frontend directory and run
cd application\frontend
streamlit run app.py --server.port 8501 --server.address localhost --browser.gatherUsageStats false

REM Return to original directory
cd ..\..

echo.
echo 👋 Demo session ended.
echo To deploy the full system, run 'terraform apply' in infrastructure/terraform/
pause
