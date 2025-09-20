# Security Hub Module Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enable_security_hub" {
  description = "Enable AWS Security Hub"
  type        = bool
  default     = false
}

variable "enable_default_standards" {
  description = "Enable default security standards"
  type        = bool
  default     = true
}

variable "enable_cis_standard" {
  description = "Enable CIS AWS Foundations Benchmark standard"
  type        = bool
  default     = true
}

variable "enable_pci_standard" {
  description = "Enable PCI DSS standard"
  type        = bool
  default     = false
}

variable "enable_nist_standard" {
  description = "Enable NIST Cybersecurity Framework standard"
  type        = bool
  default     = true
}

variable "enable_finding_aggregation" {
  description = "Enable finding aggregation across regions"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
