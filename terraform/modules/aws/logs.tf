resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "govuk-pay-cloudfront-logs-${var.environment}"
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "pass_password" "splunk_hec_token" {
  path = "splunk/paas/hec_token"
  provider = pass.low-pass
}

module "cloudfront_logging" {
  source         = "./cloudfront_logging"
  environment    = var.environment
  log_bucket_id  = aws_s3_bucket.cloudfront_logs.id
  log_bucket_arn = aws_s3_bucket.cloudfront_logs.arn
}

module "waf_logging" {
  source              = "./waf_logging"
  environment         = var.environment
  splunk_hec_endpoint = "https://http-inputs-gds.splunkcloud.com"
  splunk_hec_token    = data.pass_password.splunk_hec_token.password
}
