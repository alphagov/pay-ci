resource "cloudfoundry_app" "publicauth" {
  name    = "publicauth"
  space   = data.cloudfoundry_space.space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "publicauth" {
  domain   = data.cloudfoundry_domain.internal.id
  hostname = "publicauth${var.internal_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.publicauth.id
  }
}