variable "name" {
  type        = string
  description = "Name of this ACL (for example: my-waf-acl)"
}

variable "description" {
  type        = string
  default     = ""
  description = "Description of this ACL (for example: My WAF ACL)"
}

variable "acl" {
  type        = string
  default     = null
  description = "Optional JSON ACL config"
}

variable "log_destination" {
  type        = string
  default     = null
  description = "Optional Kinesis Firehose log destination for this ACL"
}

variable "log_redacted_fields" {
  type        = string
  default     = ""
  description = "Redacted fields config for this ACL"
}