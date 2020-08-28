variable "environment" {
  type        = string
  description = "Environment name (for example: staging)"
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "route_table_id" {
  type = string
}

variable "base_subnet" {
  type = number
}

variable "permitted_cidrs" {
  type        = list(string)
  description = "A list of CIDR blocks permitted by the RDS security group ingress rules"
}

variable "default_rds_params" {
  type        = map
  description = "A map of default settings for all RDS instances provisioned in an environment"

  default = {
    disk_size      = 20
    storage_type   = "gp2"
    engine         = "postgres"
    engine_version = "11.1"
    instance_class = "db.t3.small"
    multi_az       = false
  }
}
