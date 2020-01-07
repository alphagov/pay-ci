variable "environment" {
  type        = string
  description = "Environment name (for example: staging)"
}

variable "domain_name" {
  type        = string
  description = "Root domain name"
}

variable "enable_cloudfront" {
  description = "Create Cloudfront distribution"
  default     = true
}

variable "enable_field_level_encryption" {
  description = "Enable Cloudfront field level encryption"
  default     = false
}

variable "paas_domain" {
  type        = string
  description = "PaaS domain for Cloudfront origin"
}
