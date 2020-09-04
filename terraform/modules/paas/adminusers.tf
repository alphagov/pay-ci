locals {
  adminusers_credentials = lookup(var.credentials, "adminusers")
}

resource "cloudfoundry_app" "adminusers" {
  name    = "adminusers"
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

resource "cloudfoundry_route" "adminusers" {
  domain   = data.cloudfoundry_domain.internal.id
  hostname = "adminusers${var.internal_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.adminusers.id
  }
}

module "adminusers_credentials" {
  source               = "../credentials"
  pay_low_pass_secrets = lookup(local.adminusers_credentials, "pay_low_pass_secrets")
}

resource "cloudfoundry_user_provided_service" "adminusers_secret_service" {
  name        = "adminusers-secret-service"
  space       = data.cloudfoundry_space.space.id
  credentials = merge(module.adminusers_credentials.secrets, lookup(local.adminusers_credentials, "static_values"))
}