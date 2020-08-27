terraform {
  required_version = ">= 0.12"

  # Comment out when bootstrapping
  backend "s3" {
    bucket = "govuk-pay-test-tfstate"
    key    = "account.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  version = "~> 3.0"
  region  = "eu-west-1"

  allowed_account_ids = ["734876687119"]
}

module "state_bucket" {
  source      = "../modules/state-bucket"
  bucket_name = "govuk-pay-test-tfstate"
}

module "cyber_security_audit_role" {
  source = "git::https://github.com/alphagov/tech-ops//cyber-security/modules/gds_security_audit_role?ref=720885a9769c40942ff30b32179e1fad18f2ca10"

  chain_account_id = "988997429095"
}
