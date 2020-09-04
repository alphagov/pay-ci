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

provider "aws" {
  version = "~> 3.0"
  region  = "eu-west-1"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_db_instance" "card_connector_rds" {
  db_instance_identifier = "staging-card-connector-rds"
}

module "paas" {
  source = "../modules/paas"

  org                      = "govuk-pay"
  space                    = "staging"
  environment              = "staging"
  external_domain          = "staging.gdspay.uk"
  external_hostname_suffix = ""
  internal_hostname_suffix = "-stg"
  credentials              = var.credentials
  aws_region               = data.aws_region.current.name
  aws_account_id           = data.aws_caller_identity.current.account_id
  rds_host_names           = { card_connector = data.aws_db_instance.card_connector_rds }
}

module "paas_postgres" {
  source = "../modules/paas-postgres"

  org   = "govuk-pay"
  space = "staging"
}
