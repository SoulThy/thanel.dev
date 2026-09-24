resource "aws_route53_zone" "blog" {
  name    = var.domain_name
  comment = "My personal blog"
}

resource "aws_route53_record" "blog_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.blog.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.blog.zone_id
}

# root -> cloudfront
resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.blog.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.blog.domain_name
    zone_id                = aws_cloudfront_distribution.blog.hosted_zone_id
    evaluate_target_health = false
  }
}

# www -> root
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.blog.zone_id
  name    = local.www_domain_name
  type    = "A"

  alias {
    name                   = aws_route53_record.root.name
    zone_id                = aws_route53_zone.blog.zone_id
    evaluate_target_health = false
  }
}
