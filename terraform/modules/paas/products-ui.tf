locals {
  products_ui_credentials = lookup(var.credentials, "products_ui")
}

resource "cloudfoundry_app" "products_ui" {
  name    = "products-ui"
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

resource "cloudfoundry_route" "products_ui" {
  domain   = data.cloudfoundry_domain.external.id
  hostname = "products${var.external_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.products_ui.id
  }
}

resource "cloudfoundry_network_policy" "products_ui" {
  policy {
    source_app      = cloudfoundry_app.products_ui.id
    destination_app = cloudfoundry_app.products.id
    port            = "8080"
  }
  policy {
    source_app      = cloudfoundry_app.products_ui.id
    destination_app = cloudfoundry_app.adminusers.id
    port            = "8080"
  }
}

module "products_ui_credentials" {
  source = "../credentials"
  pay_low_pass_secrets = lookup(local.products_ui_credentials, "pay_low_pass_secrets")
}

resource "cloudfoundry_user_provided_service" "products_ui_secret_service" {
  name        = "products-ui-secret-service"
  space       = data.cloudfoundry_space.space.id
  credentials = merge(module.products_ui_credentials.secrets, lookup(local.products_ui_credentials, "static_values"))
}
