rds_instances = {
  adminusers = {
    allocated_storage = 30
    snapshot_identifier = "arn:aws:rds:eu-west-1:234617505259:snapshot:adminusers-copy"
  }
  card-connector = {
    allocated_storage = 110
    snapshot_identifier = "arn:aws:rds:eu-west-1:234617505259:snapshot:card-connector-copied-snap-shot"
  }
  ledger = {
    allocated_storage = 125
    snapshot_identifier = "arn:aws:rds:eu-west-1:234617505259:snapshot:ledger-copy"
    engine_version = "11.4"
  }
  publicauth = {
    allocated_storage = 50
    snapshot_identifier = "arn:aws:rds:eu-west-1:234617505259:snapshot:publicauth-copy"
  }
  products = {
    allocated_storage = 10
    snapshot_identifier = "arn:aws:rds:eu-west-1:234617505259:snapshot:products-copy"
  }
}
