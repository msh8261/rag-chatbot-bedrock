# CloudFront Module - Secure RAG Chatbot CloudFront Distribution

# CloudFront Distribution
resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = var.api_gateway_domain
    origin_id   = "api-gateway-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "RAG Chatbot CloudFront Distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "api-gateway-origin"

    forwarded_values {
      query_string = true
      headers      = ["Authorization", "Content-Type"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior for API calls
  ordered_cache_behavior {
    path_pattern     = "/chat/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "api-gateway-origin"

    forwarded_values {
      query_string = true
      headers      = ["Authorization", "Content-Type"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # web_acl_id = var.waf_web_acl_id  # Disabled due to access issues

  tags = var.tags
}

# CloudFront Origin Access Control (not needed for API Gateway)
# resource "aws_cloudfront_origin_access_control" "main" {
#   name                              = "${var.project_name}-${var.environment}-oac"
#   description                       = "OAC for RAG Chatbot"
#   origin_access_control_origin_type = "api-gateway"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }

# CloudFront Cache Policy
resource "aws_cloudfront_cache_policy" "main" {
  name        = "${var.project_name}-${var.environment}-cache-policy"
  comment     = "Cache policy for RAG Chatbot"
  default_ttl = 0
  max_ttl     = 31536000
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    query_strings_config {
      query_string_behavior = "all"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Authorization", "Content-Type"]
      }
    }

    cookies_config {
      cookie_behavior = "none"
    }
  }
}

# CloudFront Response Headers Policy
resource "aws_cloudfront_response_headers_policy" "main" {
  name    = "${var.project_name}-${var.environment}-response-headers-policy"
  comment = "Response headers policy for RAG Chatbot"

  security_headers_config {
    content_type_options {
      override = false
    }
    frame_options {
      frame_option = "DENY"
      override     = false
    }
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = false
    }
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
      override                   = false
    }
  }

  # Custom headers removed - X-Frame-Options is a security header
  # custom_headers_config {
  #   items {
  #     header   = "X-Frame-Options"
  #     value    = "DENY"
  #     override = false
  #   }
  # }
}
