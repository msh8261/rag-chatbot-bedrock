# Amazon Inspector Module Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "enable_inspector" {
  description = "Enable Amazon Inspector vulnerability assessment"
  type        = bool
  default     = false
}

variable "resource_types" {
  description = "Resource types to enable for Inspector scanning"
  type        = list(string)
  default     = ["EC2", "ECR", "LAMBDA"]
}

variable "enable_ec2_scanning" {
  description = "Enable EC2 scanning"
  type        = bool
  default     = true
}

variable "enable_ecr_scanning" {
  description = "Enable ECR scanning"
  type        = bool
  default     = true
}

variable "enable_lambda_scanning" {
  description = "Enable Lambda scanning"
  type        = bool
  default     = true
}

variable "assessment_duration" {
  description = "Duration of the assessment in seconds"
  type        = number
  default     = 3600
}

variable "rules_package_arns" {
  description = "ARNs of the rules packages to use"
  type        = list(string)
  default     = []
}

variable "auto_run_assessment" {
  description = "Automatically run assessment after template creation"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
