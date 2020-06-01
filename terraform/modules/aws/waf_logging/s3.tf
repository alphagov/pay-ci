resource "aws_s3_bucket" "waf_log_bucket" {
  bucket = "govuk-pay-waf-logs-${var.environment}"
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "waf_log_bucket" {
  bucket = aws_s3_bucket.waf_log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
