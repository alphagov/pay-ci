terraform {
  required_version = ">= 0.12.0"
}
provider "cloudfoundry" {
  api_url = "https://api.london.cloud.service.gov.uk"
}
data "cloudfoundry_org" "org" {
  name = "govuk-pay"
}
data "cloudfoundry_space" "sandbox" {
  name = "sandbox"
  org  = data.cloudfoundry_org.org.id
}
resource "cloudfoundry_app" "testapp" {
  name    = "testapp"
  space   = data.cloudfoundry_space.sandbox.id
  stopped = true
  v3      = true
  lifecycle {
    ignore_changes = [stopped, health_check_type]
  }
}
