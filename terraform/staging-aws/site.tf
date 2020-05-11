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


variable "splunk_hec_token" {
  type        = string
  description = "HEC Token for Splunk"
}

variable "splunk_hec_endpoint" {
  type        = string
  description = "HEC Endpoint for Splunk"  
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
  splunk_hec_endpoint = var.splunk_hec_endpoint
  splunk_hec_token = var.splunk_hec_token
}
