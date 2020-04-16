locals {
  publicauth_credentials = lookup(var.credentials, "publicauth")
}

resource "cloudfoundry_app" "publicauth" {
  name    = "publicauth"
  space   = data.cloudfoundry_space.space.id
  stopped = true
  v3      = true

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

module "publicauth_credentials" {
  source = "../credentials"
  pay_low_pass_secrets = lookup(local.publicauth_credentials, "pay_low_pass_secrets")
}

resource "cloudfoundry_user_provided_service" "publicauth_secret_service" {
  name        = "publicauth-secret-service"
  space       = data.cloudfoundry_space.space.id
  credentials = merge(module.publicauth_credentials.secrets, lookup(local.publicauth_credentials, "static_values"))
}