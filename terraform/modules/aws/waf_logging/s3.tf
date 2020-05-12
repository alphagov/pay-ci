resource "aws_s3_bucket" "waf_log_bucket" {
  bucket = "govuk-pay-waf-logs-${var.environment}"
  acl    = "private"
}
