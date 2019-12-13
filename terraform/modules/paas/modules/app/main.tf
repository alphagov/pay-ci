resource "cloudfoundry_app" "app" {
  name       = var.name
  space      = var.space_id
  memory     = var.memory
  disk_quota = var.disk_quota
  stopped    = true

  dynamic "service_binding" {
    for_each = var.needs_db ? [cloudfoundry_service_instance.db[0].id] : []

    content {
      service_instance = service_binding.value
    }
  }
}

resource "cloudfoundry_route" "app" {
  domain   = var.domain_id
  space    = var.space_id
  hostname = var.hostname

  target {
    app = cloudfoundry_app.app.id
  }
}

data "cloudfoundry_service" "postgres" {
  count = var.needs_db? 1 : 0

  name = "postgres"
}

resource "cloudfoundry_service_instance" "db" {
  count = var.needs_db? 1 : 0

  name         = "${var.name}-db"
  service_plan = data.cloudfoundry_service.postgres[0].service_plans["tiny-unencrypted-11"]
  space        = var.space_id
  json_params  = jsonencode({"enable_extensions" = ["pg_trgm"]})

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "cloudfoundry_network_policy" "app" {
  count = length(var.app_policies) > 0 ? 1 : 0

  dynamic "policy" {
    for_each = var.app_policies

    content {
      source_app      = cloudfoundry_app.app.id
      destination_app = policy.value
      port            = "8080"
    }
  }
}
