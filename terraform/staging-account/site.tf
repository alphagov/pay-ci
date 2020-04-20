terraform {
  backend "s3" {
    bucket = "govuk-pay-terraform-state"
    key    = "account"
    region = "eu-west-2"
  }
}

provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-2"
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

  lifecycle {
    prevent_destroy = true
  }
}
