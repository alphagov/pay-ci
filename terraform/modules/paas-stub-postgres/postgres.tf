locals {
  password = "mysecretpassword"
}

resource "cloudfoundry_app" "postgres" {
  name              = "postgres"
  space             = data.cloudfoundry_space.space.id
  docker_image      = "postgres:latest"
  memory            = 500
  disk_quota        = 500
  timeout           = 300
  health_check_type = "process"

  command = <<EOS
  echo "CREATE EXTENSION \"uuid-ossp\";
        CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA pg_catalog;
        CREATE USER connector WITH password 'mysecretpassword';
        CREATE DATABASE connector WITH owner=connector TEMPLATE postgres;
        GRANT ALL PRIVILEGES ON DATABASE connector TO connector;
        CREATE USER publicauth WITH password 'mysecretpassword';
        CREATE DATABASE publicauth WITH owner=publicauth TEMPLATE postgres;
        GRANT ALL PRIVILEGES ON DATABASE publicauth TO publicauth;
        CREATE USER adminusers WITH password 'mysecretpassword';
        CREATE DATABASE adminusers WITH owner=adminusers TEMPLATE postgres;
        GRANT ALL PRIVILEGES ON DATABASE adminusers TO adminusers;
        CREATE USER products WITH password 'mysecretpassword';
        CREATE DATABASE products WITH owner=products TEMPLATE postgres;
        GRANT ALL PRIVILEGES ON DATABASE products TO products;
        CREATE USER directdebit_connector WITH password 'mysecretpassword';
        CREATE DATABASE directdebit_connector WITH owner=directdebit_connector TEMPLATE postgres;
        GRANT ALL PRIVILEGES ON DATABASE directdebit_connector TO directdebit_connector;
        CREATE USER ledger WITH password 'mysecretpassword';
        CREATE DATABASE ledger WITH owner=ledger TEMPLATE postgres;
        GRANT ALL PRIVILEGES ON DATABASE ledger TO ledger;" > /docker-entrypoint-initdb.d/init.sql && \
  exec docker-entrypoint.sh postgres
  EOS

  environment = {
    POSTGRES_PASSWORD = local.password
  }
}

resource "cloudfoundry_route" "postgres" {
  space    = data.cloudfoundry_space.space.id
  hostname = "postgres-${var.space}"
  domain   = data.cloudfoundry_domain.internal.id

  target {
    app = cloudfoundry_app.postgres.id
  }
}

resource "cloudfoundry_network_policy" "postgres" {
  dynamic "policy" {
    for_each = [
      data.cloudfoundry_app.adminusers.id,
      data.cloudfoundry_app.card_connector.id,
      data.cloudfoundry_app.ledger.id,
      data.cloudfoundry_app.products.id,
      data.cloudfoundry_app.publicauth.id,
    ]

    content {
      source_app      = policy.value
      destination_app = cloudfoundry_app.postgres.id
      port            = "5432"
    }
  }
}

resource "cloudfoundry_user_provided_service" "adminusers_db" {
  name  = "adminusers-db"
  space = data.cloudfoundry_space.space.id

  credentials = {
    host       = cloudfoundry_route.postgres.endpoint
    name       = "adminusers"
    user       = "adminusers"
    password   = local.password
    ssl_option = "ssl=none"
  }
}

resource "cloudfoundry_user_provided_service" "card_connector_db" {
  name  = "card-connector-db"
  space = data.cloudfoundry_space.cde_space.id

  credentials = {
    host       = cloudfoundry_route.postgres.endpoint
    name       = "connector"
    user       = "connector"
    password   = local.password
    ssl_option = "ssl=none"
  }
}

resource "cloudfoundry_user_provided_service" "ledger_db" {
  name  = "ledger-db"
  space = data.cloudfoundry_space.space.id

  credentials = {
    host       = cloudfoundry_route.postgres.endpoint
    name       = "ledger"
    user       = "ledger"
    password   = local.password
    ssl_option = "ssl=none"
  }
}

resource "cloudfoundry_user_provided_service" "directdebit_connector_db" {
  name  = "directdebit-connector-db"
  space = data.cloudfoundry_space.space.id

  credentials = {
    host       = cloudfoundry_route.postgres.endpoint
    name       = "directdebit-connector"
    user       = "directdebit-connector"
    password   = local.password
    ssl_option = "ssl=none"
  }
}

resource "cloudfoundry_user_provided_service" "products_db" {
  name  = "products-db"
  space = data.cloudfoundry_space.space.id

  credentials = {
    host       = cloudfoundry_route.postgres.endpoint
    name       = "products"
    user       = "products"
    password   = local.password
    ssl_option = "ssl=none"
  }
}

resource "cloudfoundry_user_provided_service" "publicauth_db" {
  name  = "publicauth-db"
  space = data.cloudfoundry_space.space.id

  credentials = {
    host       = cloudfoundry_route.postgres.endpoint
    name       = "publicauth"
    user       = "publicauth"
    password   = local.password
    ssl_option = "ssl=none"
  }
}
