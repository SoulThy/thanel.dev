resource "aws_cloudfront_origin_access_control" "blog" {
  name                              = "oac-${var.project_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "blog" {
  enabled             = true
  default_root_object = "index.html"
  comment             = "Cloudfront distribution for my blog"
  price_class         = "PriceClass_100"
  is_ipv6_enabled     = true
  aliases             = [var.domain_name, local.www_domain_name]

  origin {
    domain_name              = aws_s3_bucket.blog.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.blog.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = true

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.index_rewrite.arn
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.blog.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# This lets us keep OAC in S3 and block public access while
# mantaining the following path resolution in cloudfront:
# /blog or /blog/ gives us -> /blog/index.html
resource "aws_cloudfront_function" "index_rewrite" {
  name    = "index-rewrite-${var.project_name}"
  runtime = "cloudfront-js-2.0"
  publish = true

  code = <<-EOT
  function handler(event) {
    var request = event.request;
    var uri = request.uri;

    if (uri.endsWith('/')) {
      request.uri += 'index.html';
    } else if (!uri.split('/').pop().includes('.')) {
      request.uri += '/index.html';
    }

    return request;
  }
  EOT
}
