data "cloudfoundry_app" "adminusers" {
  name_or_id = "adminusers"
  space      = data.cloudfoundry_space.space.id
}

data "cloudfoundry_app" "card_connector" {
  name_or_id = "card-connector"
  space      = data.cloudfoundry_space.cde_space.id
}

data "cloudfoundry_app" "ledger" {
  name_or_id = "ledger"
  space      = data.cloudfoundry_space.space.id
}

data "cloudfoundry_app" "products" {
  name_or_id = "products"
  space      = data.cloudfoundry_space.space.id
}

data "cloudfoundry_app" "publicauth" {
  name_or_id = "publicauth"
  space      = data.cloudfoundry_space.space.id
}
