terraform {
  backend "s3" {
    bucket = "govuk-pay-terraform-state"
    key    = "staging"
    region = "eu-west-2"
  }
}

provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-2"
}

provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
  alias   = "us"
}

provider "pass" {
  store_dir     = "../../secrets"
  refresh_store = false
}

module "staging" {
  source = "../modules/aws"

  providers = {
    aws    = aws
    aws.us = aws.us
  }

  environment       = "staging"
  domain_name       = "gdspay.uk"
  paas_domain       = "cloudapps.digital"
}
