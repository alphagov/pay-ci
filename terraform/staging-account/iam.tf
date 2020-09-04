locals {
  email_suffix = "@digital.cabinet-office.gov.uk"
}

module "dan_worth_admin" {
  source              = "git::ssh://git@github.com/alphagov/tech-ops-private.git//reliability-engineering/terraform/modules/gds-user-role?ref=43804cdf6eae5f75bf239859009c495c39db09d7"
  email               = "dan.worth${local.email_suffix}"
  role_suffix         = "admin"
  iam_policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  restrict_to_gds_ips = true
}

module "dominic_jones_admin" {
  source              = "git::ssh://git@github.com/alphagov/tech-ops-private.git//reliability-engineering/terraform/modules/gds-user-role?ref=43804cdf6eae5f75bf239859009c495c39db09d7"
  email               = "dominic.jones${local.email_suffix}"
  role_suffix         = "admin"
  iam_policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  restrict_to_gds_ips = true
}

module "richard_baker_admin" {
  source              = "git::ssh://git@github.com/alphagov/tech-ops-private.git//reliability-engineering/terraform/modules/gds-user-role?ref=43804cdf6eae5f75bf239859009c495c39db09d7"
  email               = "richard.baker${local.email_suffix}"
  role_suffix         = "admin"
  iam_policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  restrict_to_gds_ips = true
}

module "rory_malcolm_admin" {
  source              = "git::ssh://git@github.com/alphagov/tech-ops-private.git//reliability-engineering/terraform/modules/gds-user-role?ref=43804cdf6eae5f75bf239859009c495c39db09d7"
  email               = "rory.malcolm${local.email_suffix}"
  role_suffix         = "admin"
  iam_policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  restrict_to_gds_ips = true
}