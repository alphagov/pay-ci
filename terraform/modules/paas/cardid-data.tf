resource "cloudfoundry_app" "cardid_data" {
  name    = "cardid-data"
  space   = data.cloudfoundry_space.space.id
  stopped = true
  v3      = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "cardid_data" {
  domain   = data.cloudfoundry_domain.internal.id
  hostname = "cardid-data${var.internal_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.cardid_data.id
  }
}
