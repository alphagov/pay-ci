data "cloudfoundry_service" "postgres" {
  name = "postgres"
}

resource "cloudfoundry_service_instance" "adminusers_db" {
  name         = "adminusers-db"
  service_plan = data.cloudfoundry_service.postgres.service_plans["tiny-unencrypted-11"]
  space        = data.cloudfoundry_space.space.id
  json_params  = jsonencode({ "enable_extensions" = ["pg_trgm"] })

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "cloudfoundry_service_instance" "card_connector_db" {
  name         = "card-connector-db"
  service_plan = data.cloudfoundry_service.postgres.service_plans["tiny-unencrypted-11"]
  space        = data.cloudfoundry_space.cde_space.id
  json_params  = jsonencode({ "enable_extensions" = ["pg_trgm"] })

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "cloudfoundry_service_instance" "directdebit_connector_db" {
  name         = "directdebit-connector-db"
  service_plan = data.cloudfoundry_service.postgres.service_plans["tiny-unencrypted-11"]
  space        = data.cloudfoundry_space.space.id
  json_params  = jsonencode({ "enable_extensions" = ["pg_trgm"] })

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "cloudfoundry_service_instance" "ledger_db" {
  name         = "ledger-db"
  service_plan = data.cloudfoundry_service.postgres.service_plans["tiny-unencrypted-11"]
  space        = data.cloudfoundry_space.space.id
  json_params  = jsonencode({ "enable_extensions" = ["pg_trgm"] })

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "cloudfoundry_service_instance" "products_db" {
  name         = "products-db"
  service_plan = data.cloudfoundry_service.postgres.service_plans["tiny-unencrypted-11"]
  space        = data.cloudfoundry_space.space.id
  json_params  = jsonencode({ "enable_extensions" = ["pg_trgm"] })

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "cloudfoundry_service_instance" "publicauth_db" {
  name         = "publicauth-db"
  service_plan = data.cloudfoundry_service.postgres.service_plans["tiny-unencrypted-11"]
  space        = data.cloudfoundry_space.space.id
  json_params  = jsonencode({ "enable_extensions" = ["pg_trgm"] })

  timeouts {
    create = "30m"
    delete = "30m"
  }
}
