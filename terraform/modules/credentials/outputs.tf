output "secrets" {
  sensitive = true
  value = local.low_pass_values
}
