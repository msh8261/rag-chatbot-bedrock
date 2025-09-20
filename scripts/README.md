# 🚀 Frontend Launch Scripts

This directory contains PowerShell and Batch scripts to easily launch the RAG Chatbot frontend application.

## 📁 Available Scripts

### PowerShell Scripts

#### 1. `launch-frontend.ps1` (Recommended)
**Advanced launcher with auto-discovery features**

```powershell
# Basic usage
.\launch-frontend.ps1

# With auto-discovery from Terraform
.\launch-frontend.ps1 -AutoDiscover

# With custom API URL
.\launch-frontend.ps1 -ApiUrl "https://your-api.execute-api.region.amazonaws.com/prod"

# With custom port
.\launch-frontend.ps1 -Port 8502

# Show help
.\launch-frontend.ps1 -Help
```

**Features:**
- ✅ Auto-discovery of API URL from Terraform
- ✅ Automatic requirement installation
- ✅ API connectivity testing
- ✅ Environment file creation
- ✅ Comprehensive error handling
- ✅ System status display

#### 2. `run-frontend.ps1`
**Full-featured launcher with extensive options**

```powershell
# Basic usage
.\run-frontend.ps1

# With all options
.\run-frontend.ps1 -ApiUrl "https://your-api.execute-api.region.amazonaws.com/prod" -Port 8502 -Environment prod
```

**Features:**
- ✅ Interactive API URL input
- ✅ Environment configuration
- ✅ Prerequisites checking
- ✅ API connectivity testing
- ✅ Detailed logging

#### 3. `start-frontend.ps1`
**Quick and simple launcher**

```powershell
# Simple usage
.\start-frontend.ps1
```

**Features:**
- ✅ Minimal setup
- ✅ Quick startup
- ✅ Basic error handling

### Batch Scripts

#### 4. `start-frontend.bat`
**Windows Batch file for quick launch**

```cmd
# Simple usage
start-frontend.bat
```

**Features:**
- ✅ Windows native
- ✅ No PowerShell required
- ✅ Simple and fast

## 🎯 Quick Start Guide

### Option 1: Auto-Discovery (Recommended)
If you've deployed the infrastructure with Terraform:

```powershell
.\launch-frontend.ps1 -AutoDiscover
```

### Option 2: Manual Configuration
If you know your API Gateway URL:

```powershell
.\launch-frontend.ps1 -ApiUrl "https://your-api-id.execute-api.region.amazonaws.com/prod"
```

### Option 3: Simple Start
For quick testing:

```powershell
.\start-frontend.ps1
```

## 📋 Prerequisites

### Required Software
- **Python 3.11+** - [Download from python.org](https://python.org)
- **PowerShell 5.1+** (for .ps1 scripts)
- **Windows Command Prompt** (for .bat scripts)

### Required Files
- `application/frontend/app.py` - Streamlit application
- `application/frontend/requirements.txt` - Python dependencies

## 🔧 Configuration

### Environment Variables
The scripts automatically set these environment variables:

```bash
API_GATEWAY_URL=https://your-api-id.execute-api.region.amazonaws.com/prod
ENVIRONMENT=prod
```

### Port Configuration
Default port is `8501`. You can change it with:

```powershell
.\launch-frontend.ps1 -Port 8502
```

## 🚨 Troubleshooting

### Common Issues

#### 1. "Python not found"
**Solution:**
- Install Python from [python.org](https://python.org)
- Make sure Python is added to your PATH
- Restart your terminal/command prompt

#### 2. "Streamlit not found"
**Solution:**
- The scripts will try to install Streamlit automatically
- Or install manually: `pip install streamlit`

#### 3. "API URL not accessible"
**Solution:**
- Check that your API Gateway is deployed
- Verify the URL is correct
- Run `terraform apply` to deploy the backend

#### 4. "Wrong directory"
**Solution:**
- Make sure you're in the project root directory
- The directory should contain `application/frontend/app.py`

### Getting API Gateway URL

#### From Terraform Output
```bash
cd infrastructure/terraform
terraform output api_gateway_url
```

#### From AWS Console
1. Go to API Gateway in AWS Console
2. Select your API
3. Copy the Invoke URL

#### From Scripts
```powershell
python scripts/get-api-url.py
```

## 📊 Script Comparison

| Feature | launch-frontend.ps1 | run-frontend.ps1 | start-frontend.ps1 | start-frontend.bat |
|---------|---------------------|------------------|-------------------|-------------------|
| Auto-discovery | ✅ | ❌ | ❌ | ❌ |
| API testing | ✅ | ✅ | ❌ | ❌ |
| Requirements install | ✅ | ❌ | ❌ | ❌ |
| Error handling | ✅ | ✅ | ✅ | ✅ |
| Help system | ✅ | ✅ | ❌ | ❌ |
| Custom port | ✅ | ✅ | ❌ | ❌ |
| Environment config | ✅ | ✅ | ❌ | ❌ |

## 🎉 Usage Examples

### Development Workflow
```powershell
# 1. Deploy infrastructure
cd infrastructure/terraform
terraform apply

# 2. Launch frontend with auto-discovery
cd ../..
.\scripts\launch-frontend.ps1 -AutoDiscover
```

### Production Testing
```powershell
# Launch with specific configuration
.\scripts\launch-frontend.ps1 -ApiUrl "https://prod-api.execute-api.us-east-1.amazonaws.com/prod" -Port 8501
```

### Quick Testing
```powershell
# Simple launch for testing
.\scripts\start-frontend.ps1
```

## 🔗 Related Files

- `application/frontend/app.py` - Main Streamlit application
- `application/frontend/requirements.txt` - Python dependencies
- `infrastructure/terraform/outputs.tf` - Terraform outputs
- `scripts/get-api-url.py` - API URL discovery script

## 📞 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Verify all prerequisites are installed
3. Check that the backend is deployed
4. Review the error messages for specific guidance

---

*Happy coding with RAG Chatbot! 🤖*
