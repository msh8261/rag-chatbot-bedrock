import streamlit as st
import requests
import json
import uuid
from datetime import datetime
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Page configuration
st.set_page_config(
    page_title="RAG Chatbot",
    page_icon="🤖",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for better UI
st.markdown("""
<style>
    .main-header {
        font-size: 2.5rem;
        font-weight: bold;
        color: #1f77b4;
        text-align: center;
        margin-bottom: 2rem;
    }
    .chat-message {
        padding: 1rem;
        border-radius: 0.5rem;
        margin-bottom: 1rem;
        max-width: 80%;
    }
    .user-message {
        background-color: #e3f2fd;
        margin-left: auto;
        text-align: right;
    }
    .assistant-message {
        background-color: #f5f5f5;
        margin-right: auto;
    }
    .sidebar-content {
        padding: 1rem;
    }
    .security-badge {
        background-color: #4caf50;
        color: white;
        padding: 0.25rem 0.5rem;
        border-radius: 0.25rem;
        font-size: 0.8rem;
        margin: 0.25rem;
        display: inline-block;
    }
</style>
""", unsafe_allow_html=True)

# Initialize session state
if "messages" not in st.session_state:
    st.session_state.messages = []
if "session_id" not in st.session_state:
    st.session_state.session_id = str(uuid.uuid4())
if "user_id" not in st.session_state:
    st.session_state.user_id = "anonymous"

# Configuration
API_GATEWAY_URL = os.getenv("API_GATEWAY_URL", "https://your-api-gateway-url.execute-api.region.amazonaws.com/prod")
ENVIRONMENT = os.getenv("ENVIRONMENT", "prod")

def send_message(message):
    """Send message to the API Gateway"""
    try:
        response = requests.post(
            f"{API_GATEWAY_URL}/chat",
            json={
                "message": message,
                "session_id": st.session_state.session_id,
                "user_id": st.session_state.user_id
            },
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        
        if response.status_code == 200:
            return response.json()
        else:
            st.error(f"Error: {response.status_code} - {response.text}")
            return None
    except requests.exceptions.RequestException as e:
        st.error(f"Connection error: {str(e)}")
        return None

def display_security_features():
    """Display security features in sidebar"""
    st.sidebar.markdown("### 🔒 Security Features")
    st.sidebar.markdown('<span class="security-badge">End-to-End Encryption</span>', unsafe_allow_html=True)
    st.sidebar.markdown('<span class="security-badge">Input Validation</span>', unsafe_allow_html=True)
    st.sidebar.markdown('<span class="security-badge">Rate Limiting</span>', unsafe_allow_html=True)
    st.sidebar.markdown('<span class="security-badge">WAF Protection</span>', unsafe_allow_html=True)
    st.sidebar.markdown('<span class="security-badge">VPC Endpoints</span>', unsafe_allow_html=True)
    st.sidebar.markdown('<span class="security-badge">IAM Roles</span>', unsafe_allow_html=True)
    st.sidebar.markdown('<span class="security-badge">CloudTrail Logging</span>', unsafe_allow_html=True)
    st.sidebar.markdown('<span class="security-badge">GuardDuty Monitoring</span>', unsafe_allow_html=True)

def display_architecture_info():
    """Display architecture information in sidebar"""
    st.sidebar.markdown("### 🏗️ Architecture")
    st.sidebar.markdown("**Frontend:** Streamlit on ECS Fargate")
    st.sidebar.markdown("**API:** API Gateway + Lambda")
    st.sidebar.markdown("**AI:** Amazon Bedrock + Claude 3")
    st.sidebar.markdown("**Storage:** DynamoDB + S3")
    st.sidebar.markdown("**Search:** OpenSearch")
    st.sidebar.markdown("**Security:** WAF + Shield + VPC")

def main():
    # Header
    st.markdown('<h1 class="main-header">🤖 Secure RAG Chatbot</h1>', unsafe_allow_html=True)
    
    # Sidebar
    with st.sidebar:
        st.markdown("### 📊 Session Info")
        st.markdown(f"**Session ID:** `{st.session_state.session_id[:8]}...`")
        st.markdown(f"**User ID:** `{st.session_state.user_id}`")
        st.markdown(f"**Environment:** `{ENVIRONMENT}`")
        
        st.markdown("---")
        display_security_features()
        
        st.markdown("---")
        display_architecture_info()
        
        st.markdown("---")
        if st.button("🗑️ Clear Chat", type="secondary"):
            st.session_state.messages = []
            st.rerun()
    
    # Main chat interface
    col1, col2 = st.columns([4, 1])
    
    with col1:
        st.markdown("### 💬 Chat with the AI Assistant")
        st.markdown("Ask questions about your documents or have a conversation with the AI.")
    
    with col2:
        if st.button("🔄 Refresh", type="secondary"):
            st.rerun()
    
    # Display chat messages
    for message in st.session_state.messages:
        with st.chat_message(message["role"]):
            st.markdown(message["content"])
            if "timestamp" in message:
                st.caption(f"🕒 {message['timestamp']}")
    
    # Chat input
    if prompt := st.chat_input("Type your message here..."):
        # Add user message to chat
        user_message = {
            "role": "user",
            "content": prompt,
            "timestamp": datetime.now().strftime("%H:%M:%S")
        }
        st.session_state.messages.append(user_message)
        
        # Display user message
        with st.chat_message("user"):
            st.markdown(prompt)
            st.caption(f"🕒 {user_message['timestamp']}")
        
        # Get AI response
        with st.chat_message("assistant"):
            with st.spinner("🤔 Thinking..."):
                response = send_message(prompt)
            
            if response and "response" in response:
                ai_message = {
                    "role": "assistant",
                    "content": response["response"],
                    "timestamp": datetime.now().strftime("%H:%M:%S")
                }
                st.session_state.messages.append(ai_message)
                
                st.markdown(response["response"])
                st.caption(f"🕒 {ai_message['timestamp']}")
            else:
                st.error("❌ Failed to get response from the AI assistant.")
    
    # Footer
    st.markdown("---")
    st.markdown("""
    <div style="text-align: center; color: #666; font-size: 0.8rem;">
        <p>🔒 This application implements comprehensive security measures including encryption, input validation, and monitoring.</p>
        <p>Built with AWS Bedrock, Streamlit, and following AWS security best practices.</p>
    </div>
    """, unsafe_allow_html=True)

if __name__ == "__main__":
    main()
