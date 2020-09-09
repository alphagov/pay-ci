locals {
  app_catalog_urls = {
    "adminusers_url"     = "http://${cloudfoundry_route.adminusers.endpoint}:8080"
    "cardid_url"         = "http://${cloudfoundry_route.cardid.endpoint}:8080"
    "card_connector_url" = "http://${cloudfoundry_route.card_connector.endpoint}:8080"
    "card_frontend_url"  = "https://${cloudfoundry_route.card_frontend.endpoint}"
    "ledger_url"         = "http://${cloudfoundry_route.ledger.endpoint}:8080"
    "notifications_url"  = "https://${cloudfoundry_route.notifications.endpoint}"
    "products_ui_url"    = "https://${cloudfoundry_route.products_ui.endpoint}"
    "products_url"       = "http://${cloudfoundry_route.products.endpoint}:8080"
    "publicapi_url"      = "https://${cloudfoundry_route.publicapi.endpoint}"
    "publicauth_url"     = "http://${cloudfoundry_route.publicauth.endpoint}:8080"
    "selfservice_url"    = "https://${cloudfoundry_route.selfservice.endpoint}"
    "toolbox_url"        = "https://${cloudfoundry_route.toolbox.endpoint}"
    // @todo Fix these by configuring in the application(s). They should not be needed here.
    "selfservice_transactions_url" = "https://${cloudfoundry_route.selfservice.endpoint}/transactions"
    "products_ui_redirect_url"     = "https://${cloudfoundry_route.products_ui.endpoint}/redirect"
    "products_ui_pay_url"          = "https://${cloudfoundry_route.products_ui.endpoint}/pay"
    "products_ui_confirmation_url" = "https://${cloudfoundry_route.products_ui.endpoint}/payment-complete"
    "card_frontend_support_url"    = "https://${cloudfoundry_route.card_frontend.endpoint}/support"
    // Some apps require FQP. These are mapped in env-map.yml in respective app repos.
    "publicauth_api_path_url"             = "http://${cloudfoundry_route.publicauth.endpoint}:8080/v1/api/auth"
    "publicauth_frontend_path_url"        = "http://${cloudfoundry_route.publicauth.endpoint}:8080/v1/frontend/auth"
    "cardid_data_test_card_data_location" = "http://${cloudfoundry_route.cardid_data.endpoint}:8080/test-cards/test-card-bin-ranges.csv"
    "cardid_data_worldpay_data_location"  = "http://${cloudfoundry_route.cardid_data.endpoint}:8080/worldpay/GENERIC2ISOCPTISSUERPREPAID.CSV"
    "cardid_data_discover_data_location"  = "http://${cloudfoundry_route.cardid_data.endpoint}:8080/discover/Merchant_Marketing.csv"
    "carbon_relay_route"                  = "${cloudfoundry_route.carbon_relay.endpoint}"
    "carbon_relay_port"                   = "2003"
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
