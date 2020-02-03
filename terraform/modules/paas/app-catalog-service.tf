locals {
  app_catalog_urls = {
    "adminusers_url"               = "http://${cloudfoundry_route.adminusers.endpoint}:8080"
    "cardid_url"                   = "http://${cloudfoundry_route.cardid.endpoint}:8080"
    "card_connector_url"           = "http://${cloudfoundry_route.card_connector.endpoint}:8080"
    "card_frontend_url"            = "https://${cloudfoundry_route.card_frontend.endpoint}"
    "directdebit_connector_url"    = "http://${cloudfoundry_route.directdebit_connector.endpoint}:8080"
    "directdebit_frontend_url"     = "https://${cloudfoundry_route.directdebit_frontend.endpoint}"
    "ledger_url"                   = "http://${cloudfoundry_route.ledger.endpoint}:8080"
    "notifications_url"            = "https://${cloudfoundry_route.notifications.endpoint}"
    "products_ui_url"              = "https://${cloudfoundry_route.products_ui.endpoint}"
    "products_url"                 = "http://${cloudfoundry_route.products.endpoint}:8080"
    "publicapi_url"                = "https://${cloudfoundry_route.publicapi.endpoint}"
    "publicauth_url"               = "https://${cloudfoundry_route.publicauth.endpoint}"
    "selfservice_url"              = "https://${cloudfoundry_route.selfservice.endpoint}"
    "selfservice_transactions_url" = "https://${cloudfoundry_route.selfservice.endpoint}/transactions"
    "toolbox_url"                  = "https://${cloudfoundry_route.toolbox.endpoint}"
  }
}

resource "cloudfoundry_user_provided_service" "app_catalog" {
  name        = "app-catalog"
  space       = data.cloudfoundry_space.space.id
  credentials = local.app_catalog_urls
}

resource "cloudfoundry_user_provided_service" "app_catalog_cde" {
  name        = "app-catalog"
  space       = data.cloudfoundry_space.cde_space.id
  credentials = local.app_catalog_urls
}
