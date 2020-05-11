resource "aws_route53_record" "directdebit_frontend" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "directdebit-frontend.${local.subdomain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.directdebit_frontend.domain_name
    zone_id                = aws_cloudfront_distribution.directdebit_frontend.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_cloudfront_distribution" "directdebit_frontend" {
  depends_on = [
    aws_acm_certificate.cert,
    aws_acm_certificate_validation.cert,
  ]

  enabled             = true
  wait_for_deployment = false
  comment             = "${var.environment}-directdebit-frontend"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
  }

  aliases = ["directdebit-frontend.${var.environment}.${var.domain_name}"]

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
    domain_name = var.paas_domain

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

  web_acl_id = module.direct_debit_frontend_waf_acl.acl_id
}

module direct_debit_frontend_waf_acl {
  source          = "./waf_v2_acl" 
  name            = "direct-debit-frontend-${var.environment}"
  description     = "Direct Debit Frontend ACL ${var.environment}"
  log_destination = module.waf_logging.kinesis_stream_id
}
