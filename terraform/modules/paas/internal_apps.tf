module "app_adminusers" {
  source = "./modules/app"

  name      = "adminusers"
  hostname  = "adminusers-${var.space}"
  space_id  = data.cloudfoundry_space.space.id
  domain_id = data.cloudfoundry_domain.internal.id
  needs_db  = var.postgres_container ? false : true
}

module "app_card-connector" {
  source = "./modules/app"

  name      = "card-connector"
  hostname  = "card-connector-${var.space}"
  space_id  = data.cloudfoundry_space.cde_space.id
  domain_id = data.cloudfoundry_domain.internal.id
  needs_db  = var.postgres_container ? false : true
}

module "app_cardid" {
  source = "./modules/app"

  name      = "cardid"
  hostname  = "cardid-${var.space}"
  space_id  = data.cloudfoundry_space.cde_space.id
  domain_id = data.cloudfoundry_domain.internal.id
}

module "app_directdebit-connector" {
  source = "./modules/app"

  name      = "directdebit-connector"
  hostname  = "directdebit-connector-${var.space}"
  space_id  = data.cloudfoundry_space.space.id
  domain_id = data.cloudfoundry_domain.internal.id
  needs_db  = var.postgres_container ? false : true
}

module "app_directdebit-frontend" {
  source = "./modules/app"

  name      = "directdebit-frontend"
  hostname  = "${local.hostname_prefix}directdebit-frontend${local.hostname_suffix}"
  space_id  = data.cloudfoundry_space.space.id
  domain_id = data.cloudfoundry_domain.internal.id

  app_policies = [
    module.app_adminusers.app.id,
    module.app_directdebit-connector.app.id,
  ]
}

module "app_ledger" {
  source = "./modules/app"

  name      = "ledger"
  hostname  = "ledger-${var.space}"
  space_id  = data.cloudfoundry_space.space.id
  domain_id = data.cloudfoundry_domain.internal.id
  needs_db  = var.postgres_container ? false : true
}

module "app_products" {
  source = "./modules/app"

  name      = "products"
  hostname  = "products-${var.space}"
  space_id  = data.cloudfoundry_space.space.id
  domain_id = data.cloudfoundry_domain.internal.id
  needs_db  = var.postgres_container ? false : true
}
