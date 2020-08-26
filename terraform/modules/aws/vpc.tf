data "aws_availability_zones" "available" {}

resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${var.environment}-route"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.default.id

  # Omitting all ingress {} and egress {} blocks to deny by default.
  # Nothing should use this security group, but it cannot be deleted.
}
