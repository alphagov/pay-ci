resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "govuk-pay-cloudfront-logs-${var.environment}"
  acl    = "private"
}

data "pass_password" "splunk_hec_token" {
  path = "splunk/paas/hec_token"
  provider = pass.low-pass
}

module "waf_logging" {
  source              = "./waf_logging"
  environment         = var.environment
  splunk_hec_endpoint = "https://http-inputs-gds.splunkcloud.com"
  splunk_hec_token    = data.pass_password.splunk_hec_token.password
}