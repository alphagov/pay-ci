locals {
  selfservice_credentials = lookup(var.credentials, "selfservice")
}

resource "cloudfoundry_app" "selfservice" {
  name    = "selfservice"
  space   = data.cloudfoundry_space.space.id
  stopped = true
  v3      = true

  service_binding {
    service_instance = cloudfoundry_service_instance.splunk_log_service.id
  }

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "selfservice" {
  domain   = data.cloudfoundry_domain.external.id
  hostname = "selfservice${var.external_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.selfservice.id
  }
}

resource "cloudfoundry_network_policy" "selfservice" {
  policy {
    source_app      = cloudfoundry_app.selfservice.id
    destination_app = cloudfoundry_app.adminusers.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.selfservice.id
    destination_app = cloudfoundry_app.card_connector.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.selfservice.id
    destination_app = cloudfoundry_app.ledger.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.selfservice.id
    destination_app = cloudfoundry_app.products.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.selfservice.id
    destination_app = cloudfoundry_app.publicauth.id
    port            = "8080"
  }
}

module "selfservice_credentials" {
  source               = "../credentials"
  pay_low_pass_secrets = lookup(local.selfservice_credentials, "pay_low_pass_secrets")
  pay_dev_pass_secrets = lookup(local.selfservice_credentials, "pay_dev_pass_secrets")
}

resource "cloudfoundry_user_provided_service" "selfservice_secret_service" {
  name        = "selfservice-secret-service"
  space       = data.cloudfoundry_space.space.id
  credentials = merge(module.selfservice_credentials.secrets, lookup(local.selfservice_credentials, "static_values"))
}
