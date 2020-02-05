resource "cloudfoundry_app" "directdebit_frontend" {
  name    = "directdebit-frontend"
  space   = data.cloudfoundry_space.space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "directdebit_frontend" {
  domain   = data.cloudfoundry_domain.external.id
  hostname = "directdebit-frontend${var.external_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.directdebit_frontend.id
  }
}

resource "cloudfoundry_network_policy" "directdebit_frontend" {
  policy {
    source_app      = cloudfoundry_app.directdebit_frontend.id
    destination_app = cloudfoundry_app.adminusers.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.directdebit_frontend.id
    destination_app = cloudfoundry_app.directdebit_connector.id
    port            = "8080"
  }
}
