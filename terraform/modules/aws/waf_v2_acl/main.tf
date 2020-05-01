locals {
  acl_rules = templatefile("${path.module}/rules.tpl", {})
}

data "external" "aws_waf_v2_acl" {
  program = ["ruby", "${path.module}/fetch_aws_wafv2.rb"]

  query = {
    name = var.name
  }
}

resource "null_resource" "aws_waf_v2_acl" {
  triggers = {
    name        = var.name
    description = "'${var.description}'"
    acl_rules   = local.acl_rules
  }

  provisioner "local-exec" {
    command = "${path.module}/configure_aws_wafv2.rb configure --name ${self.triggers.name} --description ${self.triggers.description} --acl '${self.triggers.acl_rules}'"
  }
}
