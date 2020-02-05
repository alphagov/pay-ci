resource "cloudfoundry_app" "directdebit_connector" {
  name    = "directdebit-connector"
  space   = data.cloudfoundry_space.space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "directdebit_connector" {
  domain   = data.cloudfoundry_domain.internal.id
  hostname = "directdebit-connector${var.internal_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.directdebit_connector.id
  }
}
