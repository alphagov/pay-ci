resource "cloudfoundry_app" "products_ui" {
  name    = "products-ui"
  space   = data.cloudfoundry_space.space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "products_ui" {
  domain   = data.cloudfoundry_domain.external.id
  hostname = "products${var.external_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.products_ui.id
  }
}

resource "cloudfoundry_network_policy" "products_ui" {
  policy {
    source_app      = cloudfoundry_app.products_ui.id
    destination_app = cloudfoundry_app.products.id
    port            = "8080"
  }
}
