resource "aws_route53_record" "publicapi" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "publicapi.${local.subdomain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.publicapi.domain_name
    zone_id                = aws_cloudfront_distribution.publicapi.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_cloudfront_distribution" "publicapi" {
  depends_on = [
    aws_acm_certificate_validation.cert,
  ]

  enabled = true
  comment = "${var.environment}-publicapi"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
  }

  aliases = ["publicapi.${var.environment}.${var.domain_name}"]

  default_cache_behavior {
    target_origin_id       = "paas"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = 0
    max_ttl                = 0
    default_ttl            = 0

    forwarded_values {
      headers      = ["Host", "Origin", "Authorization"]
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  origin {
    origin_id   = "paas"
    domain_name = "${var.paas_domain}"

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
