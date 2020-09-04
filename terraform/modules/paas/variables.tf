variable "org" {
  type        = string
  description = "PaaS organisation"
}

variable "space" {
  type        = string
  description = "PaaS space"
}

variable "environment" {
  type        = string
  description = "The application environment e.g. dev, staging or production"
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

variable "credentials" {
  type        = map(map(map(string)))
  description = "credential for the apps"
}

variable "aws_region" {
  type        = string
  description = "Name of AWS region to use in configuration values e.g. eu-west-2"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account id to use in configuration passed to user provided services etc."
}

variable "rds_host_names" {
  type        = map
  description = "Map of rds host names for the apps"
}
