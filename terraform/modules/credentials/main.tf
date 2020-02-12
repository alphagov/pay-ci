locals {
  /* This needs some careful checking. If keys() and values() do not 
  return the corresponding hash keys and values in the same order then the
  zipped result will have the wrong value for a key. Perhaps there's a better way*/
  low_pass_values = zipmap(keys(data.pass_password.secret), values(data.pass_password.secret).*.password)
}

provider "pass" {
  store_dir = "../../../pay-low-pass"
  refresh_store = false
}

data "pass_password" "secret" {
  for_each = var.pay_low_pass_secrets
  path = each.value
}

