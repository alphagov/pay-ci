locals {
  card_frontend_credentials = lookup(var.credentials, "card_frontend")
}

resource "cloudfoundry_app" "card_frontend" {
  name    = "card-frontend"
  space   = data.cloudfoundry_space.cde_space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "card_frontend" {
  domain   = data.cloudfoundry_domain.external.id
  hostname = "card-frontend${var.external_hostname_suffix}"
  space    = data.cloudfoundry_space.cde_space.id

  target {
    app = cloudfoundry_app.card_frontend.id
  }
}

resource "cloudfoundry_network_policy" "card_frontend" {
  policy {
    source_app      = cloudfoundry_app.card_frontend.id
    destination_app = cloudfoundry_app.adminusers.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.card_frontend.id
    destination_app = cloudfoundry_app.cardid.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.card_frontend.id
    destination_app = cloudfoundry_app.card_connector.id
    port            = "8080"
  }
}

module "card_frontend_credentials" {
  source = "../credentials"
  pay_low_pass_secrets = lookup(local.card_frontend_credentials, "pay_low_pass_secrets")
}

resource "cloudfoundry_user_provided_service" "card_frontend_secret_service" {
  name        = "card-frontend-secret-service"
  space       = data.cloudfoundry_space.cde_space.id
  credentials = merge(module.card_frontend_credentials.secrets, lookup(local.card_frontend_credentials, "static_values"))
}
