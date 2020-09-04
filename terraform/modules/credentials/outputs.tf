output "secrets" {
  sensitive = true
  value     = merge(local.low_pass_values, local.dev_pass_values)
}