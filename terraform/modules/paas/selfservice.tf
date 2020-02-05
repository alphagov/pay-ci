resource "cloudfoundry_app" "selfservice" {
  name    = "selfservice"
  space   = data.cloudfoundry_space.space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "selfservice" {
  domain   = data.cloudfoundry_domain.external.id
  hostname = "selfservice${var.external_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.selfservice.id
  }
}

resource "cloudfoundry_network_policy" "selfservice" {
  policy {
    source_app      = cloudfoundry_app.selfservice.id
    destination_app = cloudfoundry_app.adminusers.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.selfservice.id
    destination_app = cloudfoundry_app.card_connector.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.selfservice.id
    destination_app = cloudfoundry_app.directdebit_connector.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.selfservice.id
    destination_app = cloudfoundry_app.ledger.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.selfservice.id
    destination_app = cloudfoundry_app.products.id
    port            = "8080"
  }
}
