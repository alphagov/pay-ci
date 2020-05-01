resource "aws_route53_record" "products_ui" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "products.${local.subdomain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.products_ui.domain_name
    zone_id                = aws_cloudfront_distribution.products_ui.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_cloudfront_distribution" "products_ui" {
  depends_on = [
    aws_acm_certificate.cert,
    aws_acm_certificate_validation.cert,
  ]

  enabled             = true
  wait_for_deployment = false
  comment             = "${var.environment}-products"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
  }

  aliases = ["products.${var.environment}.gdspay.uk"]

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

module products_ui_waf_acl {
  source      = "./waf_v2_acl" 
  name        = "products-ui-${var.environment}"
  description = "Products UI ACL ${var.environment}"
}
