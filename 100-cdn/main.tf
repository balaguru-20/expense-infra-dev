resource "aws_cloudfront_distribution" "expense" {
  origin {
    domain_name = "${var.project_name}.${var.environment}.${var.domain_name}"
    origin_id   = "${var.project_name}.${var.environment}.${var.domain_name}"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled = true

  aliases = ["${var.project_name}-cdn.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "PUT", "POST"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.project_name}-${var.environment}.${var.domain_name}"

    viewer_protocol_policy = "https-only"
    cache_policy_id        = data.aws_cloudfront_cache_policy.noCache.id
  }

  #Cahche beheviour with procedence 0
  ordered_cache_behavior {
    path_pattern     = "/images/"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.project_name}.${var.environment}.${var.domain_name}"

    viewer_protocol_policy = "https-only"
    cache_policy_id        = data.aws_cloudfront_cache_policy.cacheEnabled.id
  }

  #Cahche beheviour with procedence 1
  ordered_cache_behavior {
    path_pattern     = "/static/"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.project_name}.${var.environment}.${var.domain_name}"

    viewer_protocol_policy = "https-only"
    cache_policy_id        = data.aws_cloudfront_cache_policy.cacheEnabled.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["IN"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = local.https_certificate_arn
    ssl_support_method       = "sni-only" #HTTPS only
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}"
    }
  )
}

resource "aws_route53_record" "cdn" {
  zone_id = var.zone_id
  name    = "expense-cdn${var.environment}.${var.domain_name}"
  type    = "A"

  #These are ALB DNS name and zone information
  alias {
    name                   = aws_cloudfront_distribution.expense.domain_name
    zone_id                = aws_cloudfront_distribution.expense.hosted_zone_id
    evaluate_target_health = false
  }
  allow_overwrite = true
}