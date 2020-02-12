resource "cloudfoundry_app" "publicapi" {
  name    = "publicapi"
  space   = data.cloudfoundry_space.space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "publicapi" {
  domain   = data.cloudfoundry_domain.external.id
  hostname = "publicapi${var.external_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.publicapi.id
  }
}

resource "cloudfoundry_network_policy" "publicapi" {
  policy {
    source_app      = cloudfoundry_app.publicapi.id
    destination_app = cloudfoundry_app.card_connector.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.publicapi.id
    destination_app = cloudfoundry_app.directdebit_connector.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.publicapi.id
    destination_app = cloudfoundry_app.publicauth.id
    port            = "8080"
  }
}

module "publicapi_credentials" {
  source = "../credentials"
  pay_low_pass_secrets = lookup(var.publicapi_credentials, "pay_low_pass_secrets")
}

resource "cloudfoundry_user_provided_service" "publicapi_secret_service" {
  name        = "publicapi-serect-service"
  space       = data.cloudfoundry_space.space.id
  credentials = merge(module.publicapi_credentials.secrets, lookup(var.publicapi_credentials, "static_values"))
}
