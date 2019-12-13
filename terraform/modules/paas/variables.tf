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

variable "dev_environment" {
  type        = bool
  description = "Is this a dev environment?"
}

variable "separate_cde" {
  type        = bool
  description = "Whether to provision a separate CDE space"
}

variable "postgres_container" {
  default     = false
  description = "Whether to provision the dummy postgres container app"
}

variable "sqs_container" {
  default     = false
  description = "Whether to provision the dummy sqs container app"
}
