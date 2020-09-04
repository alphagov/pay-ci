locals {
  ledger_credentials = lookup(var.credentials, "ledger")
}

resource "cloudfoundry_app" "ledger" {
  name    = "ledger"
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

resource "cloudfoundry_route" "ledger" {
  domain   = data.cloudfoundry_domain.internal.id
  hostname = "ledger${var.internal_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.ledger.id
  }
}

module "ledger_credentials" {
  source               = "../credentials"
  pay_low_pass_secrets = lookup(local.ledger_credentials, "pay_low_pass_secrets")
}

resource "cloudfoundry_user_provided_service" "ledger_secret_service" {
  name        = "ledger-secret-service"
  space       = data.cloudfoundry_space.space.id
  credentials = merge(module.ledger_credentials.secrets, lookup(local.ledger_credentials, "static_values"))
}
