locals {
  carbon_relay_credentials = lookup(var.credentials, "carbon-relay")
}

resource "cloudfoundry_app" "carbon-relay" {
  name    = "carbon-relay"
  space   = data.cloudfoundry_space.space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "carbon_relay" {
  domain   = data.cloudfoundry_domain.internal.id
  hostname = "carbon-relay${var.internal_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.carbon-relay.id
  }
}

module "carbon_relay_credentials" {
  source = "../credentials"
  pay_low_pass_secrets = lookup(local.carbon_relay_credentials, "pay_low_pass_secrets")
}

resource "cloudfoundry_user_provided_service" "carbon_relay_secret_service" {
  name        = "carbon-relay-secret-service"
  space       = data.cloudfoundry_space.space.id
  credentials = merge(module.carbon_relay_credentials.secrets, lookup(local.carbon_relay_credentials, "static_values"))
}
