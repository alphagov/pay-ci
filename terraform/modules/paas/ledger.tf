resource "cloudfoundry_app" "ledger" {
  name    = "ledger"
  space   = data.cloudfoundry_space.space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "ledger" {
  domain   = data.cloudfoundry_domain.internal.id
  hostname = "ledger${var.internal_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.ledger.id
  }
}
