resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name

  tags = {
    Environment = var.environment
  }
}

resource "aws_acm_certificate" "cert" {
  provider = aws.us

  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = aws_route53_zone.hosted_zone.id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  zone_id         = each.value.zone_id
  records         = [each.value.record]
  ttl             = 60
}

resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.us
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
