provider "cloudfoundry" {
  version = "0.10.0"
  api_url = "https://api.london.cloud.service.gov.uk"
}

variable "space" {}

module "paas" {
  source = "../modules/paas"

  org                      = "govuk-pay"
  space                    = var.space
  external_domain          = "london.cloudapps.digital"
  external_hostname_suffix = "-${var.space}"
  internal_hostname_suffix = "-${var.space}"
}

module "paas_postgres" {
  source = "../modules/paas-stub-postgres"

  org   = "govuk-pay"
  space = var.space
}

module "paas_sqs" {
  source = "../modules/paas-stub-sqs"

  org   = "govuk-pay"
  space = var.space
}
