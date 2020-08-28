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
