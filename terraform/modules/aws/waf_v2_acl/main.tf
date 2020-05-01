provider "aws" {
  alias = "us"
}

data "external" "aws_waf_v2_acl" {
  program = ["ruby", "${path.module}/configure_aws_wafv2.rb"]

  query = {
    name = var.name
    description = var.description
    rules = templatefile("${path.module}/rules.tpl", {})
  }
}