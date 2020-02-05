resource "cloudfoundry_app" "notifications" {
  name    = "notifications"
  space   = data.cloudfoundry_space.space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "notifications" {
  domain   = data.cloudfoundry_domain.external.id
  hostname = "notifications${var.external_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.notifications.id
  }
}

resource "cloudfoundry_network_policy" "notifications" {
  policy {
    source_app      = cloudfoundry_app.notifications.id
    destination_app = cloudfoundry_app.card_connector.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.notifications.id
    destination_app = cloudfoundry_app.directdebit_connector.id
    port            = "8080"
  }
}
