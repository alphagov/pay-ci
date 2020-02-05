resource "cloudfoundry_app" "toolbox" {
  name    = "toolbox"
  space   = data.cloudfoundry_space.space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "toolbox" {
  domain   = data.cloudfoundry_domain.external.id
  hostname = "toolbox${var.external_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.toolbox.id
  }
}

resource "cloudfoundry_network_policy" "toolbox" {
  policy {
    source_app      = cloudfoundry_app.toolbox.id
    destination_app = cloudfoundry_app.adminusers.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.toolbox.id
    destination_app = cloudfoundry_app.card_connector.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.toolbox.id
    destination_app = cloudfoundry_app.directdebit_connector.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.toolbox.id
    destination_app = cloudfoundry_app.ledger.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.toolbox.id
    destination_app = cloudfoundry_app.products.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.toolbox.id
    destination_app = cloudfoundry_app.publicauth.id
    port            = "8080"
  }
}
