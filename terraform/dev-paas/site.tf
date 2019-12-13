provider "cloudfoundry" {
  version = "0.15.0"
  api_url = "https://api.london.cloud.service.gov.uk"
}

variable "space" {}

module "paas" {
  source = "../modules/paas"

  org             = "govuk-pay"
  space           = var.space
  external_domain = "london.cloudapps.digital"
  dev_environment = true
  separate_cde    = false

  postgres_container = true
  sqs_container      = true
}
