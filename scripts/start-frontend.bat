@echo off
REM RAG Chatbot Frontend Launcher - Batch File
REM Simple batch file to launch the Streamlit frontend

echo.
echo 🤖 RAG Chatbot Frontend - Quick Start
echo =====================================
echo.

REM Check if we're in the right directory
if not exist "application\frontend\app.py" (
    echo ❌ Error: Please run this script from the project root directory
    echo    Current directory: %CD%
    echo    Expected: RAG chatbot project root
    pause
    exit /b 1
)

REM Get API URL from user
echo 🔗 Enter your API Gateway URL:
echo    Example: https://abc123def4.execute-api.ap-southeast-1.amazonaws.com/prod
set /p API_URL="API URL: "

if "%API_URL%"=="" (
    echo ❌ API URL is required
    pause
    exit /b 1
)

REM Set environment variables
set API_GATEWAY_URL=%API_URL%
set ENVIRONMENT=prod

echo.
echo 🚀 Starting frontend...
echo    API URL: %API_URL%
echo    Port: 8501
echo    Browser will open automatically
echo.
echo Press Ctrl+C to stop
echo.

REM Change to frontend directory and run
cd application\frontend
streamlit run app.py --server.port 8501 --server.address localhost

REM Return to original directory
cd ..\..

echo.
echo 👋 Frontend session ended.
echo Thank you for using RAG Chatbot!
pause
