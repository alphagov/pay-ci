resource "cloudfoundry_app" "products" {
  name    = "products"
  space   = data.cloudfoundry_space.space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "products" {
  domain   = data.cloudfoundry_domain.internal.id
  hostname = "products${var.internal_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.products.id
  }
}
