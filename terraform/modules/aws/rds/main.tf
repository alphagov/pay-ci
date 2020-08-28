locals {
  databases = []
}

resource "aws_db_instance" "default" {

  for_each = local.databases

  identifier = "${var.environment}-${each.value.name}-rds"

  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group
}