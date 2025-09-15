# ECS Module - Secure RAG Chatbot ECS Cluster and Service

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ECR Repository for Frontend
resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}-${var.environment}-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true


  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = var.tags
}

# ECR Repository Policy
resource "aws_ecr_repository_policy" "frontend" {
  repository = aws_ecr_repository.frontend.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPushPull"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}

# ECS Cluster Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_name}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn           = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name  = "rag-chatbot-frontend"
      image = "${aws_ecr_repository.frontend.repository_url}:latest"
      
      portMappings = [
        {
          containerPort = 8501
          hostPort      = 8501
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "API_GATEWAY_URL"
          value = var.api_gateway_url
        },
        {
          name  = "ENVIRONMENT"
          value = var.environment
        }
      ]
      

      command = [
        "/bin/bash",
        "-c",
        "pip install streamlit requests boto3 python-dotenv && echo 'import streamlit as st\nimport requests\nimport json\nimport uuid\nfrom datetime import datetime\nimport os\n\n# Load .env file for local development (if exists)\ntry:\n    from dotenv import load_dotenv\n    load_dotenv()\nexcept ImportError:\n    pass  # dotenv not available, environment variables set by ECS\n\n# Environment variables are set by ECS task definition in production\n# For local development, use: python scripts/get-api-url.py\n\n# Page configuration\nst.set_page_config(\n    page_title=\"RAG Chatbot\",\n    page_icon=\"🤖\",\n    layout=\"wide\",\n    initial_sidebar_state=\"expanded\"\n)\n\n# Get API Gateway URL from environment variable\nAPI_GATEWAY_URL = os.getenv(\"API_GATEWAY_URL\", \"https://362r2dpx1l.execute-api.ap-southeast-1.amazonaws.com/prod\")\n\n# Main application\ndef main():\n    st.title(\"🤖 RAG Chatbot\")\n    st.markdown(\"Ask questions and get intelligent responses powered by AWS Bedrock.\")\n    \n    # Initialize session state\n    if \"messages\" not in st.session_state:\n        st.session_state.messages = []\n    \n    if \"session_id\" not in st.session_state:\n        st.session_state.session_id = str(uuid.uuid4())\n    \n    # Display chat messages\n    for message in st.session_state.messages:\n        with st.chat_message(message[\"role\"]):\n            st.markdown(message[\"content\"])\n    \n    # Chat input\n    if prompt := st.chat_input(\"What would you like to know?\"):\n        # Add user message to chat history\n        st.session_state.messages.append({\"role\": \"user\", \"content\": prompt})\n        \n        # Display user message\n        with st.chat_message(\"user\"):\n            st.markdown(prompt)\n        \n        # Get response from API\n        with st.chat_message(\"assistant\"):\n            with st.spinner(\"Thinking...\"):\n                try:\n                    response = requests.post(\n                        f\"{API_GATEWAY_URL}/chat\",\n                        json={\n                            \"message\": prompt,\n                            \"session_id\": st.session_state.session_id\n                        },\n                        timeout=30\n                    )\n                    \n                    if response.status_code == 200:\n                        data = response.json()\n                        assistant_message = data.get(\"response\", \"Sorry, I could not process your request.\")\n                        \n                        # Add assistant message to chat history\n                        st.session_state.messages.append({\"role\": \"assistant\", \"content\": assistant_message})\n                        \n                        # Display assistant message\n                        st.markdown(assistant_message)\n                    else:\n                        error_msg = f\"Error: {response.status_code} - {response.text}\"\n                        st.error(error_msg)\n                        st.session_state.messages.append({\"role\": \"assistant\", \"content\": error_msg})\n                        \n                except requests.exceptions.RequestException as e:\n                    error_msg = f\"Connection error: {str(e)}\"\n                    st.error(error_msg)\n                    st.session_state.messages.append({\"role\": \"assistant\", \"content\": error_msg})\n                except Exception as e:\n                    error_msg = f\"Unexpected error: {str(e)}\"\n                    st.error(error_msg)\n                    st.session_state.messages.append({\"role\": \"assistant\", \"content\": error_msg})\n    \n    # Sidebar\n    with st.sidebar:\n        st.header(\"Settings\")\n        st.write(f\"**API Gateway URL:**\")\n        st.code(API_GATEWAY_URL)\n        \n        st.write(f\"**Session ID:**\")\n        st.code(st.session_state.session_id)\n        \n        if st.button(\"Clear Chat History\"):\n            st.session_state.messages = []\n            st.rerun()\n        \n        st.markdown(\"---\")\n        st.markdown(\"**About**\")\n        st.markdown(\"This chatbot uses AWS Bedrock for AI responses and is deployed on AWS ECS.\")\n\nif __name__ == \"__main__\":\n    main()' > app.py && streamlit run app.py --server.port=8501 --server.address=0.0.0.0"
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
      
      healthCheck = {
        command = [
          "CMD-SHELL",
          "curl -f http://localhost:8501/_stcore/health || exit 1"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = var.tags
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "rag-chatbot-frontend"
    container_port   = 8501
  }

  depends_on = [
    aws_lb_listener.main,
    aws_iam_role_policy_attachment.ecs_task_execution
  ]

  tags = var.tags
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = var.tags
}

# ALB Target Group
resource "aws_lb_target_group" "main" {
  name        = "${var.project_name}-${var.environment}-tg-v2"
  port        = 8501
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/_stcore/health"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# ALB Listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = var.tags
}

# ALB Listener for HTTPS (if certificate provided)
resource "aws_lb_listener" "https" {
  count = var.certificate_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = var.tags
}

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/aws/ecs/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days
  # kms_key_id        = var.kms_key_id  # Removed to avoid dependency issues

  tags = var.tags
}

# IAM Role Policy Attachment for ECS Task Execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = var.ecs_execution_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

