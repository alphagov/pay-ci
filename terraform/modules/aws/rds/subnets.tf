data "aws_availability_zones" "available" {}

// Creates a /24 subnet in each avaialbility zone starting at the provided base subnet
resource "aws_subnet" "rds_subnet" {
  for_each = toset(data.aws_availability_zones.available.names)

  vpc_id            = var.vpc_id
  availability_zone = each.value
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, index(data.aws_availability_zones.available.names, each.value))

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.environment}-rds-${index(data.aws_availability_zones.available.names, each.value) + 1}"
  }
}

resource "aws_route_table_association" "rds_subnet" {
  for_each = aws_subnet.rds_subnet

  subnet_id      = each.value.id
  route_table_id = var.route_table_id
}

resource "aws_security_group" "application_rds" {
  name        = "${var.environment}-sg-rds"
  description = "${var.environment} RDS database security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-sg-rds"
  }
}

resource "aws_security_group_rule" "permit_postgres_from_paas_to_rds" {
  type     = "ingress"
  protocol = "tcp"

  cidr_blocks       = var.permitted_cidrs
  security_group_id = aws_security_group.application_rds.id

  from_port = 5432
  to_port   = 5432
}