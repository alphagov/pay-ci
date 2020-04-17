locals {
  cardid_credentials = lookup(var.credentials, "cardid")
}

resource "cloudfoundry_app" "cardid" {
  name    = "cardid"
  space   = data.cloudfoundry_space.cde_space.id
  stopped = true
  v3      = true

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

resource "cloudfoundry_network_policy" "cardid" {
  policy {
    source_app      = cloudfoundry_app.cardid.id
    destination_app = cloudfoundry_app.cardid_data.id
    port            = "8080"
  }
}

module "cardid_credentials" {
  source = "../credentials"
  pay_low_pass_secrets = lookup(local.cardid_credentials, "pay_low_pass_secrets")
}

resource "cloudfoundry_user_provided_service" "cardid_secret_service" {
  name        = "cardid-secret-service"
  space       = data.cloudfoundry_space.cde_space.id
  credentials = merge(module.cardid_credentials.secrets, lookup(local.cardid_credentials, "static_values"))
}
