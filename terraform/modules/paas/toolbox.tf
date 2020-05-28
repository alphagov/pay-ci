locals {
  toolbox_credentials = lookup(var.credentials, "toolbox")
}

resource "cloudfoundry_app" "toolbox" {
  name    = "toolbox"
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

resource "cloudfoundry_route" "toolbox" {
  domain   = data.cloudfoundry_domain.paas_external.id
  hostname = "toolbox${var.internal_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.toolbox.id
  }
}

resource "cloudfoundry_network_policy" "toolbox" {
  policy {
    source_app      = cloudfoundry_app.toolbox.id
    destination_app = cloudfoundry_app.adminusers.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.toolbox.id
    destination_app = cloudfoundry_app.card_connector.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.toolbox.id
    destination_app = cloudfoundry_app.directdebit_connector.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.toolbox.id
    destination_app = cloudfoundry_app.ledger.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.toolbox.id
    destination_app = cloudfoundry_app.products.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.toolbox.id
    destination_app = cloudfoundry_app.publicauth.id
    port            = "8080"
  }
}

module "toolbox_credentials" {
  source = "../credentials"
  pay_low_pass_secrets = lookup(local.toolbox_credentials, "pay_low_pass_secrets")
}

resource "cloudfoundry_user_provided_service" "toolbox_secret_service" {
  name        = "toolbox-secret-service"
  space       = data.cloudfoundry_space.space.id
  credentials = merge(module.toolbox_credentials.secrets, lookup(local.toolbox_credentials, "static_values"))
}
