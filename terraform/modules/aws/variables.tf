variable "environment" {
  type        = string
  description = "Environment name (for example: staging)"
}

variable "domain_name" {
  type        = string
  description = "Root domain name"
}

variable "paas_domain" {
  type        = string
  description = "PaaS domain for Cloudfront origin"
}
