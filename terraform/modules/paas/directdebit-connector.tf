locals {
  directdebit_connector_credentials = lookup(var.credentials, "directdebit_connector")
}

resource "cloudfoundry_app" "directdebit_connector" {
  name    = "directdebit-connector"
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

resource "cloudfoundry_route" "directdebit_connector" {
  domain   = data.cloudfoundry_domain.internal.id
  hostname = "directdebit-connector${var.internal_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.directdebit_connector.id
  }
}

module "directdebit_connector_credentials" {
  source               = "../credentials"
  pay_low_pass_secrets = lookup(local.directdebit_connector_credentials, "pay_low_pass_secrets")
  pay_dev_pass_secrets = lookup(local.directdebit_connector_credentials, "pay_dev_pass_secrets")
}

resource "cloudfoundry_user_provided_service" "directdebit_connector_secret_service" {
  name        = "directdebit-connector-secret-service"
  space       = data.cloudfoundry_space.space.id
  credentials = merge(module.directdebit_connector_credentials.secrets, lookup(local.directdebit_connector_credentials, "static_values"))
}
