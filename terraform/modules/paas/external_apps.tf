locals {
  hostname_prefix = var.dev_environment ? "pay-" : ""
  hostname_suffix = var.dev_environment ? "-${var.space}" : ""
}


module "app_card-frontend" {
  source = "./modules/app"

  name      = "card-frontend"
  hostname  = "${local.hostname_prefix}card-frontend${local.hostname_suffix}"
  space_id  = data.cloudfoundry_space.cde_space.id
  domain_id = data.cloudfoundry_domain.external.id

  app_policies = [
    module.app_adminusers.app.id,
    module.app_card-connector.app.id,
    module.app_cardid.app.id,
  ]
}

module "app_products-ui" {
  source = "./modules/app"

  name      = "products-ui"
  hostname  = "${local.hostname_prefix}products${local.hostname_suffix}"
  space_id  = data.cloudfoundry_space.space.id
  domain_id = data.cloudfoundry_domain.external.id

  app_policies = [
    module.app_products.app.id,
  ]
}

module "app_publicapi" {
  source = "./modules/app"

  name      = "publicapi"
  hostname  = "${local.hostname_prefix}publicapi${local.hostname_suffix}"
  space_id  = data.cloudfoundry_space.space.id
  domain_id = data.cloudfoundry_domain.external.id

  app_policies = [
    module.app_card-connector.app.id,
    module.app_directdebit-connector.app.id,
  ]
}

module "app_publicauth" {
  source = "./modules/app"

  name      = "publicauth"
  hostname  = "${local.hostname_prefix}publicauth${local.hostname_suffix}"
  space_id  = data.cloudfoundry_space.space.id
  domain_id = data.cloudfoundry_domain.external.id
  needs_db  = var.postgres_container ? false : true
}

module "app_selfservice" {
  source = "./modules/app"

  name      = "selfservice"
  hostname  = "${local.hostname_prefix}selfservice${local.hostname_suffix}"
  space_id  = data.cloudfoundry_space.space.id
  domain_id = data.cloudfoundry_domain.external.id

  app_policies = [
    module.app_adminusers.app.id,
    module.app_card-connector.app.id,
    module.app_directdebit-connector.app.id,
    module.app_ledger.app.id,
    module.app_products.app.id,
  ]
}

module "app_notifications" {
  source = "./modules/app"

  name      = "notifications"
  hostname  = "${local.hostname_prefix}notifications${local.hostname_suffix}"
  space_id  = data.cloudfoundry_space.space.id
  domain_id = data.cloudfoundry_domain.external.id

  app_policies = [
    module.app_card-connector.app.id,
    module.app_directdebit-connector.app.id,
  ]
}

module "app_toolbox" {
  source = "./modules/app"

  name      = "toolbox"
  hostname  = "${local.hostname_prefix}toolbox${local.hostname_suffix}"
  space_id  = data.cloudfoundry_space.space.id
  domain_id = data.cloudfoundry_domain.external.id

  app_policies = [
    module.app_adminusers.app.id,
    module.app_card-connector.app.id,
    module.app_directdebit-connector.app.id,
    module.app_ledger.app.id,
    module.app_products.app.id,
    module.app_publicauth.app.id,
  ]
}
