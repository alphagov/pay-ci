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

variable "paas_vpc_peering_name" {
  type        = string
  description = "The name of the vpc peering connection with PaaS"
  default     = "pcx-0d726a5057505ab0b"
}

variable "paas_public_ips" {
  type    = list
  default = ["52.208.24.161", "52.208.1.143", "52.51.250.21"]
}

variable "paas_ireland_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_cidr" {
  type        = string
  description = "The default VPC cidr range for this environment. This may differ between environments to support VPC peering without overlapping ranges."
  default     = "172.16.0.0/16"
}

variable "subnet_reservations" {
  type        = map
  description = "A map of base subnets in the environment. Gaps must be equal or greater than the number of AZs in a region."

  default = {
    "rds" = 0
  }
}

variable "rds_instances" {
  type    = map
  default = {}
}
