resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "govuk-pay-cloudfront-logs-${var.environment}"
  acl    = "private"
}

module "waf_logging" {
  source = "./waf_logging"
  environment = var.environment
  splunk_hec_endpoint = var.splunk_hec_endpoint
  splunk_hec_token = var.splunk_hec_token
}