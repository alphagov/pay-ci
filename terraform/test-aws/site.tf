terraform {
  backend "s3" {
    bucket = "govuk-pay-test-tfstate"
    key    = "test.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  version = "~> 3.0"
  region  = "eu-west-1"

  allowed_account_ids = ["734876687119"]
}

provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
  alias   = "us"

  allowed_account_ids = ["734876687119"]
}

provider "pass" {
  version       = "~> 1.2"
  store_dir     = "../../secrets"
  refresh_store = false
}

provider "pass" {
  version       = "~> 1.2"
  store_dir     = "../../../pay-low-pass"
  refresh_store = false
  alias         = "low-pass"
}

variable "rds_instances" {
  type    = map
  default = {}
}

module "test" {
  source = "../modules/aws"

  providers = {
    aws           = aws
    aws.us        = aws.us
    pass          = pass
    pass.low-pass = pass.low-pass
  }

  environment           = "test"
  domain_name           = "test.gdspay.uk"
  paas_domain           = "cloudapps.digital"
  vpc_cidr              = "172.17.0.0/16"
  paas_vpc_peering_name = null
  rds_instances         = var.rds_instances
  subnet_reservations = {
    "rds" = 36
  }
}
