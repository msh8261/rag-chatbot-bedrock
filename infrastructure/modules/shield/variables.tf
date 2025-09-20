# AWS Shield Module Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enable_shield_advanced" {
  description = "Enable AWS Shield Advanced protection"
  type        = bool
  default     = false
}

variable "resource_arn" {
  description = "ARN of the resource to protect with Shield"
  type        = string
  default     = ""
}

variable "health_check_arn" {
  description = "ARN of the health check for Shield protection"
  type        = string
  default     = null
}

variable "response_team_contact_arn" {
  description = "ARN of the response team contact for Shield"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
