resource "cloudfoundry_app" "card_frontend" {
  name    = "card-frontend"
  space   = data.cloudfoundry_space.cde_space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "card_frontend" {
  domain   = data.cloudfoundry_domain.external.id
  hostname = "card-frontend${var.external_hostname_suffix}"
  space    = data.cloudfoundry_space.cde_space.id

  target {
    app = cloudfoundry_app.card_frontend.id
  }
}

resource "cloudfoundry_network_policy" "card_frontend" {
  policy {
    source_app      = cloudfoundry_app.card_frontend.id
    destination_app = cloudfoundry_app.adminusers.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.card_frontend.id
    destination_app = cloudfoundry_app.cardid.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.card_frontend.id
    destination_app = cloudfoundry_app.card_connector.id
    port            = "8080"
  }
}
