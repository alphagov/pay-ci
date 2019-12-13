provider "cloudfoundry" {
  version = "0.15.0"
  api_url = "https://api.cloud.service.gov.uk"
}

module "paas" {
  source = "../modules/paas"

  org             = "govuk-pay"
  space           = "staging"
  external_domain = "staging.gdspay.uk"
  dev_environment = false
  separate_cde    = true

  postgres_container = false
  sqs_container      = true
}
