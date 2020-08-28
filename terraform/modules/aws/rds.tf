data "aws_availability_zones" "available" {}

module "rds" {
  source = "./rds"

  environment     = var.environment
  vpc_id          = aws_vpc.default.id
  vpc_cidr        = aws_vpc.default.cidr_block
  route_table_id  = aws_route_table.default.id
  base_subnet     = var.subnet_reservations.rds
  permitted_cidrs = [var.paas_ireland_cidr]
}