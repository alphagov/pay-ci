locals {
  card_connector_credentials = lookup(var.credentials, "card_connector")
}

resource "cloudfoundry_app" "card_connector" {
  name    = "card-connector"
  space   = data.cloudfoundry_space.cde_space.id
  stopped = true
  v3      = true

  service_binding {
    service_instance = cloudfoundry_service_instance.cde_splunk_log_service.id
  }

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "card_connector" {
  domain   = data.cloudfoundry_domain.internal.id
  hostname = "card-connector${var.internal_hostname_suffix}"
  space    = data.cloudfoundry_space.cde_space.id

  target {
    app = cloudfoundry_app.card_connector.id
  }
}

module "card_connector_credentials" {
  source               = "../credentials"
  pay_low_pass_secrets = lookup(local.card_connector_credentials, "pay_low_pass_secrets")
}

resource "cloudfoundry_user_provided_service" "card_connector_secret_service" {
  name        = "card-connector-secret-service"
  space       = data.cloudfoundry_space.cde_space.id
  credentials = merge(module.card_connector_credentials.secrets, lookup(local.card_connector_credentials, "static_values"))
}
