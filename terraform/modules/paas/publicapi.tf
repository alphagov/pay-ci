resource "cloudfoundry_app" "publicapi" {
  name    = "publicapi"
  space   = data.cloudfoundry_space.space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "publicapi" {
  domain   = data.cloudfoundry_domain.external.id
  hostname = "publicapi${var.external_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.publicapi.id
  }
}

resource "cloudfoundry_network_policy" "publicapi" {
  policy {
    source_app      = cloudfoundry_app.publicapi.id
    destination_app = cloudfoundry_app.card_connector.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.publicapi.id
    destination_app = cloudfoundry_app.directdebit_connector.id
    port            = "8080"
  }
}
