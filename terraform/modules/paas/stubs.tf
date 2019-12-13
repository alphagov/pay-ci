resource "cloudfoundry_app" "postgres" {
  count = var.postgres_container ? 1 : 0

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
    POSTGRES_PASSWORD = "mysecretpassword"
  }
}

resource "cloudfoundry_route" "postgres" {
  count = var.postgres_container ? 1 : 0

  space    = data.cloudfoundry_space.space.id
  hostname = "postgres-${var.space}"
  domain   = data.cloudfoundry_domain.internal.id

  target {
    app = cloudfoundry_app.postgres[0].id
  }
}

resource "cloudfoundry_network_policy" "postgres" {
  count = var.postgres_container ? 1 : 0

  dynamic "policy" {
    for_each = [
      module.app_adminusers.app.id,
      module.app_card-connector.app.id,
      module.app_directdebit-connector.app.id,
      module.app_ledger.app.id,
      module.app_products.app.id,
    ]

    content {
      source_app      = policy.value
      destination_app = cloudfoundry_app.postgres[0].id
      port            = "5432"
    }
  }
}

resource "cloudfoundry_app" "sqs" {
  count = var.sqs_container ? 1 : 0

  name              = "sqs"
  space             = data.cloudfoundry_space.space.id
  docker_image      = "roribio16/alpine-sqs@sha256:2651d01db38cc9faa8184a4c87a93d95aa2aa3bb992b9e41ea6b4742dc8893bb"
  memory            = 500
  disk_quota        = 500
  timeout           = 300
  health_check_type = "process"

  command = "mkdir -p /opt/custom; echo \"$EMQ_CONFIG\" | base64 -d > /opt/custom/elasticmq.conf; exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf"

  environment = {
    EMQ_CONFIG = "bm9kZS1hZGRyZXNzIHsKICBwcm90b2NvbCA9IGh0dHAKICBob3N0ID0gIioiCiAgcG9ydCA9IDkzMjQKICBjb250ZXh0LXBhdGggPSAiIgp9CgpyZXN0LXNxcyB7CiAgZW5hYmxlZCA9IHRydWUKICBiaW5kLXBvcnQgPSA5MzI0CiAgYmluZC1ob3N0bmFtZSA9ICIwLjAuMC4wIgogIC8vIFBvc3NpYmxlIHZhbHVlczogcmVsYXhlZCwgc3RyaWN0CiAgc3FzLWxpbWl0cyA9IHN0cmljdAp9CgpxdWV1ZXMgewogIGRlZmF1bHQgewogICAgZGVmYXVsdFZpc2liaWxpdHlUaW1lb3V0ID0gMTAgc2Vjb25kcwogICAgZGVsYXkgPSA1IHNlY29uZHMKICAgIHJlY2VpdmVNZXNzYWdlV2FpdCA9IDAgc2Vjb25kcwogIH0KCiAgcGF5X2NhcHR1cmVfcXVldWUgewogICAgZGVmYXVsdFZpc2liaWxpdHlUaW1lb3V0ID0gMzYwMCBzZWNvbmRzCiAgICBkZWxheSA9IDAgc2Vjb25kcwogICAgcmVjZWl2ZU1lc3NhZ2VXYWl0ID0gNSBzZWNvbmRzCiAgfQoKICBwYXlfZXZlbnRfcXVldWUgewogICAgZGVmYXVsdFZpc2liaWxpdHlUaW1lb3V0ID0gMzYwMCBzZWNvbmRzCiAgICBkZWxheSA9IDAgc2Vjb25kcwogICAgcmVjZWl2ZU1lc3NhZ2VXYWl0ID0gNSBzZWNvbmRzCiAgfQp9Cgpha2thLmh0dHAuc2VydmVyLnBhcnNpbmcuaWxsZWdhbC1oZWFkZXItd2FybmluZ3MgPSBvZmYKYWtrYS5odHRwLnNlcnZlci5yZXF1ZXN0LXRpbWVvdXQgPSA0MCBzZWNvbmRzCg=="
  }
}

resource "cloudfoundry_route" "sqs" {
  count = var.sqs_container ? 1 : 0

  space    = data.cloudfoundry_space.space.id
  hostname = "sqs-${var.space}"
  domain   = data.cloudfoundry_domain.internal.id

  target {
    app = cloudfoundry_app.sqs[0].id
  }
}

resource "cloudfoundry_network_policy" "sqs" {
  count = var.sqs_container ? 1 : 0

  dynamic "policy" {
    for_each = [
      module.app_card-connector.app.id,
      module.app_ledger.app.id,
    ]

    content {
      source_app      = policy.value
      destination_app = cloudfoundry_app.sqs[0].id
      port            = "9324"
    }
  }
}
