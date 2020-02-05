resource "cloudfoundry_app" "cardid" {
  name    = "cardid"
  space   = data.cloudfoundry_space.cde_space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "cardid" {
  domain   = data.cloudfoundry_domain.internal.id
  hostname = "cardid${var.internal_hostname_suffix}"
  space    = data.cloudfoundry_space.cde_space.id

  target {
    app = cloudfoundry_app.cardid.id
  }
}
