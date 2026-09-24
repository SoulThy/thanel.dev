locals {
  www_domain_name = "www.${var.domain_name}"
  s3_origin_id    = "S3-${var.domain_name}"
}
