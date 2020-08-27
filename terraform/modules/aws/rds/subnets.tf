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