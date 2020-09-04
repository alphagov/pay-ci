locals {
  directdebit_frontend_credentials = lookup(var.credentials, "directdebit_frontend")
}

resource "cloudfoundry_app" "directdebit_frontend" {
  name    = "directdebit-frontend"
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

resource "cloudfoundry_route" "directdebit_frontend" {
  domain   = data.cloudfoundry_domain.external.id
  hostname = "directdebit-frontend${var.external_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.directdebit_frontend.id
  }
}

resource "cloudfoundry_network_policy" "directdebit_frontend" {
  policy {
    source_app      = cloudfoundry_app.directdebit_frontend.id
    destination_app = cloudfoundry_app.adminusers.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.directdebit_frontend.id
    destination_app = cloudfoundry_app.directdebit_connector.id
    port            = "8080"
  }
}

module "directdebit_frontend_credentials" {
  source               = "../credentials"
  pay_low_pass_secrets = lookup(local.directdebit_frontend_credentials, "pay_low_pass_secrets")
}

resource "cloudfoundry_user_provided_service" "directdebit_frontend_secret_service" {
  name        = "directdebit-frontend-secret-service"
  space       = data.cloudfoundry_space.space.id
  credentials = merge(module.directdebit_frontend_credentials.secrets, lookup(local.directdebit_frontend_credentials, "static_values"))
}
