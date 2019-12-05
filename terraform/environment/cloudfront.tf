resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "govuk-pay-cloudfront-logs-${var.environment}"
  acl    = "private"
}

resource "aws_cloudfront_distribution" "main" {
  enabled = "true"
  comment = "cloudfront-${var.environment}"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
  }

  aliases = ["*.staging.gdspay.uk"]

  default_cache_behavior {
    target_origin_id       = "paas_london"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = 0
    max_ttl                = 0
    default_ttl            = 0

    forwarded_values {
      headers      = ["Host", "Origin"]
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  origin {
    origin_id   = "paas_london"
    domain_name = "london.cloudapps.digital"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }
}
