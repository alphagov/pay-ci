locals {
  metric_exporter_credentials = lookup(var.credentials, "metric_exporter")
}

resource "cloudfoundry_app" "metric_exporter" {
  name    = "metric-exporter"
  space   = data.cloudfoundry_space.space.id
  stopped = true
  v3      = true

  service_binding { 
    service_instance = cloudfoundry_service_instance.cde_splunk_log_service.id
  }

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

module "metric_exporter_credentials" {
  source = "../credentials"
  pay_low_pass_secrets = lookup(local.metric_exporter_credentials, "pay_low_pass_secrets")
}

resource "cloudfoundry_user_provided_service" "metric_exporter_secret_service" {
  name        = "metric-exporter-secret-service"
  space       = data.cloudfoundry_space.space.id
  credentials = merge(module.metric_exporter_credentials.secrets, lookup(local.metric_exporter_credentials, "static_values"))
}
