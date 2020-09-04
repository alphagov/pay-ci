provider "pass" {
  version       = "~> 1.2"
  store_dir     = "../../../pay-low-pass"
  refresh_store = false
  alias         = "low-pass"
}

data "pass_password" "db_passwords" {
  for_each = var.rds_instances
  path     = "aws/paas/staging/rds/superuser/${replace(each.key, "-", "_")}/payment-password"
  provider = pass.low-pass
}

resource "aws_db_instance" "postgres" {
  for_each = var.rds_instances

  identifier = "${var.environment}-${each.key}-rds"

  allocated_storage   = try(each.value.allocated_storage, var.default_rds_params.allocated_storage)
  storage_type        = try(each.value.storage_type, var.default_rds_params.storage_type)
  storage_encrypted   = true
  engine              = try(each.value.engine, var.default_rds_params.engine)
  engine_version      = try(each.value.engine_version, var.default_rds_params.engine_version)
  instance_class      = try(each.value.instance_class, var.default_rds_params.instance_class)
  multi_az            = try(each.value.multi_az, var.default_rds_params.multi_az)
  skip_final_snapshot = true
  snapshot_identifier = try(each.value.snapshot_identifier, null)
  username            = "payments"
  password            = "data.db_passwords.${each.key}"

  vpc_security_group_ids = [aws_security_group.application_rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  lifecycle {
    ignore_changes = [snapshot_identifier]
  }
}
