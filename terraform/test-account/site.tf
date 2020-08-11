terraform {
  required_version = "= 0.11.14"

  # Comment out when bootstrapping
  backend "s3" {
    bucket = "govuk-pay-test-tfstate"
    key    = "account.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["734876687119"]
}

module "state_bucket" {
  source = "git::ssh://git@github.com/alphagov/tech-ops-private.git//reliability-engineering/terraform/modules/state-bucket"

  bucket_name = "govuk-pay-test-tfstate"
}

module "toby_lorne_admin" {
  source              = "git::ssh://git@github.com/alphagov/tech-ops-private.git//reliability-engineering/terraform/modules/gds-user-role/"
  email               = "toby.lornewelch-richards@digital.cabinet-office.gov.uk"
  role_suffix         = "admin"
  iam_policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  restrict_to_gds_ips = true
}

module "alex_monk_admin" {
  source              = "git::ssh://git@github.com/alphagov/tech-ops-private.git//reliability-engineering/terraform/modules/gds-user-role/"
  email               = "alex.monk@digital.cabinet-office.gov.uk"
  role_suffix         = "admin"
  iam_policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  restrict_to_gds_ips = true
}

module "richard_baker_admin" {
  source              = "git::ssh://git@github.com/alphagov/tech-ops-private.git//reliability-engineering/terraform/modules/gds-user-role/"
  email               = "richard.baker@digital.cabinet-office.gov.uk"
  role_suffix         = "admin"
  iam_policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  restrict_to_gds_ips = true
}

module "dan_worth_admin" {
  source              = "git::ssh://git@github.com/alphagov/tech-ops-private.git//reliability-engineering/terraform/modules/gds-user-role/"
  email               = "dan.worth@digital.cabinet-office.gov.uk"
  role_suffix         = "admin"
  iam_policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  restrict_to_gds_ips = true
}

module "rory_malcolm_admin" {
  source              = "git::ssh://git@github.com/alphagov/tech-ops-private.git//reliability-engineering/terraform/modules/gds-user-role/"
  email               = "rory.malcolm@digital.cabinet-office.gov.uk"
  role_suffix         = "admin"
  iam_policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  restrict_to_gds_ips = true
}

module "cyber_security_audit_role" {
  source = "git::https://github.com/alphagov/tech-ops//cyber-security/modules/gds_security_audit_role?ref=13f54e554b8f56f34f975447a1011a03321c92b6"

  chain_account_id = "988997429095"
}
