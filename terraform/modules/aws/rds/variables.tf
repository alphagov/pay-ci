variable "use_rds" {
  type = bool
}

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