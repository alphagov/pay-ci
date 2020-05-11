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

variable "splunk_hec_token" {
  type        = string
  description = "HEC Token for Splunk"
}

variable "splunk_hec_endpoint" {
  type        = string
  description = "HEC Endpoint for Splunk"  
}