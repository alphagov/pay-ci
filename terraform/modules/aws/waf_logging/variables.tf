variable "environment" {
  type        = string
  description = "Environment name (for example: staging)"
}

variable "splunk_hec_token" {
  type        = string
  description = "HEC Token for Splunk"
}

variable "splunk_hec_endpoint" {
  type        = string
  description = "HEC Endpoint for Splunk"
}