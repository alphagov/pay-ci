terraform {
  required_version = ">= 0.12.0"

  required_providers {
    cloudfoundry = ">= 0.11.0"
  }

  backend "s3" {
    bucket = "govuk-pay-terraform-state"
    key    = "staging-paas"
    region = "eu-west-2"
  }
}

provider "cloudfoundry" {
  version = "0.11.0"
  api_url = "https://api.cloud.service.gov.uk"
}

module "paas" {
  source = "../modules/paas"

  org                      = "govuk-pay"
  space                    = "staging"
  external_domain          = "staging.gdspay.uk"
  external_hostname_suffix = ""
  internal_hostname_suffix = "-stg"
  publicapi_credentials = var.publicapi_credentials
}

module "paas_postgres" {
  source = "../modules/paas-postgres"

  org   = "govuk-pay"
  space = "staging"
}

module "paas_sqs" {
  source = "../modules/paas-stub-sqs"

  org   = "govuk-pay"
  space = "staging"
}
