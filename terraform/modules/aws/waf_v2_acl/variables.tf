variable "name" {
  type        = string
  description = "Name of this ACL (for example: my-waf-acl)"
}

variable "description" {
  type    = string
  default = ""
  description = "Description of this ACL (for example: My WAF ACL)"
}