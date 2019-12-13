variable "name" {}

variable "hostname" {
  type        = string
  description = "App hostname"
}

variable "space_id" {
  type        = string
  description = "Space ID to deploy this app"
}

variable "domain_id" {
  type        = string
  default     = null
  description = "Domain ID to use for this app"
}

variable "app_policies" {
  type        = list(string)
  default     = []
  description = "App GUIDs to which this app has HTTP access"
}

variable "needs_db" {
  default     = false
  description = "Provision a Postgres service instance"
}

variable "memory" {
  default = 500
}

variable "disk_quota" {
  default = 500
}
