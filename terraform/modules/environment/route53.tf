locals {
  subdomain = "${var.environment}.${var.domain_name}"
}

data "aws_route53_zone" "root" {
  name = var.domain_name
}

resource "aws_acm_certificate" "cert" {
  provider = "aws.us"

  domain_name               = local.subdomain
  subject_alternative_names = ["*.${local.subdomain}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.root.id
  records = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  provider = "aws.us"

  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

resource "aws_route53_record" "cloudfront" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "*.${local.subdomain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = true
  }
}
