resource "cloudfoundry_app" "card_connector" {
  name    = "card-connector"
  space   = data.cloudfoundry_space.cde_space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "card_connector" {
  domain   = data.cloudfoundry_domain.internal.id
  hostname = "card-connector${var.internal_hostname_suffix}"
  space    = data.cloudfoundry_space.cde_space.id

  target {
    app = cloudfoundry_app.card_connector.id
  }
}
