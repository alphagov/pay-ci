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
