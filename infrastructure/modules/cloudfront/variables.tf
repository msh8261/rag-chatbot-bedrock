# CloudFront Module - Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "api_gateway_domain" {
  description = "Domain name of the API Gateway"
  type        = string
}

variable "waf_web_acl_id" {
  description = "WAF Web ACL ID"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
