terraform {
  backend "s3" {
    bucket = "govuk-pay-terraform-state"
    key    = "tfstate"
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
  store_dir     = "../secrets"
  refresh_store = false
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "govuk-pay-terraform-state"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
}

module "staging" {
  source = "./environment"

  providers = {
    aws    = "aws"
    aws.us = "aws.us"
  }

  environment = "staging"
  domain_name = "gdspay.uk"
}
