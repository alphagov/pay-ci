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

variable "paas_public_ips" {
  type    = list
  default = ["52.208.24.161", "52.208.1.143", "52.51.250.21"]
}

variable "vpc_cidr" {
  type        = string
  description = "The default VPC cidr range for this environment. This may differ between environments to support VPC peering without overlapping ranges."
  default     = "172.16.0.0/16"
}