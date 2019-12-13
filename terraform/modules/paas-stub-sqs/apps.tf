data "cloudfoundry_app" "card_connector" {
  name_or_id = "card-connector"
  space      = data.cloudfoundry_space.cde_space.id
}

data "cloudfoundry_app" "ledger" {
  name_or_id = "ledger"
  space      = data.cloudfoundry_space.space.id
}
