resource "cloudfoundry_app" "adminusers" {
  name    = "adminusers"
  space   = data.cloudfoundry_space.space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "adminusers" {
  domain   = data.cloudfoundry_domain.internal.id
  hostname = "adminusers${var.internal_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.adminusers.id
  }
}
