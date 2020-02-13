locals {
  products_credentials = lookup(var.credentials, "products")
}

resource "cloudfoundry_app" "products" {
  name    = "products"
  space   = data.cloudfoundry_space.space.id
  stopped = true

  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}

resource "cloudfoundry_route" "products" {
  domain   = data.cloudfoundry_domain.internal.id
  hostname = "products${var.internal_hostname_suffix}"
  space    = data.cloudfoundry_space.space.id

  target {
    app = cloudfoundry_app.products.id
  }
}

module "products_credentials" {
  source = "../credentials"
  pay_low_pass_secrets = lookup(local.products_credentials, "pay_low_pass_secrets")
}

resource "cloudfoundry_user_provided_service" "products_secret_service" {
  name        = "products-secret-service"
  space       = data.cloudfoundry_space.space.id
  credentials = merge(module.products_credentials.secrets, lookup(local.products_credentials, "static_values"))
}
