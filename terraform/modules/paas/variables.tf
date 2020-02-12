variable "org" {
  type        = string
  description = "PaaS organisation"
}

variable "space" {
  type        = string
  description = "PaaS space"
}

variable "external_domain" {
  type        = string
  description = "Domain for external app routes"
}

variable "internal_hostname_suffix" {
  type        = string
  description = "Suffix to avoid route collisions from other apps on *.apps.internal (for example, -bob would give cardid-bob.apps.internal and so on)"
  default     = ""
}

variable "external_hostname_suffix" {
  type        = string
  description = "Suffix to avoid route collisions when multiple spaces share the same domain (for example, -bob would give card-frontend-bob.cloudapps.digital and so on)"
  default     = ""
}

variable "publicapi_credentials" {
  type        = map(map(string))
  description = "credential for publicapi"
}
