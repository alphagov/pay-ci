resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "govuk-pay-cloudfront-logs-${var.environment}"
  acl    = "private"
}
