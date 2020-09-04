variable "pay_low_pass_secrets" {
  type = map(string)
}

variable "pay_dev_pass_secrets" {
  type    = map(string)
  default = {}
}
