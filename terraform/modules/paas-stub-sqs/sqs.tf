resource "cloudfoundry_app" "sqs" {
  name              = "sqs"
  space             = data.cloudfoundry_space.space.id
  docker_image      = "roribio16/alpine-sqs@sha256:2651d01db38cc9faa8184a4c87a93d95aa2aa3bb992b9e41ea6b4742dc8893bb"
  timeout           = 300
  health_check_type = "process"

  command = "mkdir -p /opt/custom; echo \"$EMQ_CONFIG\" | base64 -d > /opt/custom/elasticmq.conf; exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf"

  environment = {
    EMQ_CONFIG = "bm9kZS1hZGRyZXNzIHsKICBwcm90b2NvbCA9IGh0dHAKICBob3N0ID0gIioiCiAgcG9ydCA9IDkzMjQKICBjb250ZXh0LXBhdGggPSAiIgp9CgpyZXN0LXNxcyB7CiAgZW5hYmxlZCA9IHRydWUKICBiaW5kLXBvcnQgPSA5MzI0CiAgYmluZC1ob3N0bmFtZSA9ICIwLjAuMC4wIgogIC8vIFBvc3NpYmxlIHZhbHVlczogcmVsYXhlZCwgc3RyaWN0CiAgc3FzLWxpbWl0cyA9IHN0cmljdAp9CgpxdWV1ZXMgewogIGRlZmF1bHQgewogICAgZGVmYXVsdFZpc2liaWxpdHlUaW1lb3V0ID0gMTAgc2Vjb25kcwogICAgZGVsYXkgPSA1IHNlY29uZHMKICAgIHJlY2VpdmVNZXNzYWdlV2FpdCA9IDAgc2Vjb25kcwogIH0KCiAgcGF5X2NhcHR1cmVfcXVldWUgewogICAgZGVmYXVsdFZpc2liaWxpdHlUaW1lb3V0ID0gMzYwMCBzZWNvbmRzCiAgICBkZWxheSA9IDAgc2Vjb25kcwogICAgcmVjZWl2ZU1lc3NhZ2VXYWl0ID0gNSBzZWNvbmRzCiAgfQoKICBwYXlfZXZlbnRfcXVldWUgewogICAgZGVmYXVsdFZpc2liaWxpdHlUaW1lb3V0ID0gMzYwMCBzZWNvbmRzCiAgICBkZWxheSA9IDAgc2Vjb25kcwogICAgcmVjZWl2ZU1lc3NhZ2VXYWl0ID0gNSBzZWNvbmRzCiAgfQp9Cgpha2thLmh0dHAuc2VydmVyLnBhcnNpbmcuaWxsZWdhbC1oZWFkZXItd2FybmluZ3MgPSBvZmYKYWtrYS5odHRwLnNlcnZlci5yZXF1ZXN0LXRpbWVvdXQgPSA0MCBzZWNvbmRzCg=="
  }
}

resource "cloudfoundry_route" "sqs" {
  space    = data.cloudfoundry_space.space.id
  hostname = "sqs-${var.space}"
  domain   = data.cloudfoundry_domain.internal.id

  target {
    app = cloudfoundry_app.sqs.id
  }
}

resource "cloudfoundry_network_policy" "sqs" {
  dynamic "policy" {
    for_each = [
      data.cloudfoundry_app.card_connector.id,
      data.cloudfoundry_app.ledger.id,
    ]

    content {
      source_app      = policy.value
      destination_app = cloudfoundry_app.sqs.id
      port            = "9324"
    }
  }
}

locals {
  sqs_credentials = {
    access_key                    = "x"
    secret_key                    = "x"
    non_standard_service_endpoint = "true"
    region                        = "region-1"
    endpoint                      = "http://${cloudfoundry_route.sqs.endpoint}:9324"
    capture_queue_url             = "http://${cloudfoundry_route.sqs.endpoint}:9324/queue/pay_capture_queue"
    event_queue_url               = "http://${cloudfoundry_route.sqs.endpoint}:9324/queue/pay_event_queue"
  }
}

resource "cloudfoundry_user_provided_service" "sqs-cde" {
  name  = "sqs"
  space = data.cloudfoundry_space.cde_space.id

  credentials = local.sqs_credentials
}

resource "cloudfoundry_user_provided_service" "sqs" {
  name  = "sqs"
  space = data.cloudfoundry_space.space.id

  credentials = local.sqs_credentials
}

