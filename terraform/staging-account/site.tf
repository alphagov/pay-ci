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

  allowed_account_ids = ["234617505259"]
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

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "cyber_security_audit_role" {
  source = "git::https://github.com/alphagov/tech-ops//cyber-security/modules/gds_security_audit_role?ref=13f54e554b8f56f34f975447a1011a03321c92b6"

  chain_account_id = "988997429095"
}
