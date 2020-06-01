locals {
  /* This needs some careful checking. If keys() and values() do not 
  return the corresponding hash keys and values in the same order then the
  zipped result will have the wrong value for a key. Perhaps there's a better way*/
  low_pass_values = zipmap(keys(data.pass_password.secret), values(data.pass_password.secret).*.full)
  dev_pass_values = zipmap(keys(data.pass_password.dev_secret), values(data.pass_password.dev_secret).*.full)
}

provider "pass" {
  version       = "~> 1.2"
  store_dir     = "../../../pay-low-pass"
  refresh_store = false
}

provider "pass" {
  version       = "~> 1.2"
  store_dir     = "../../../pay-dev-pass"
  refresh_store = false
  alias         = "dev-pass"
}

data "pass_password" "secret" {
  for_each = var.pay_low_pass_secrets
  path     = each.value
}

data "pass_password" "dev_secret" {
  for_each = var.pay_dev_pass_secrets
  path     = each.value
  provider = pass.dev-pass
}
