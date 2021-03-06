locals {
  s3_origin_id = "static_content-prod"
}

resource "aws_cloudfront_origin_access_identity" "site" {
  comment = "Cloudfront identity for the site"
}

resource "aws_cloudfront_distribution" "site" {
  origin {
    domain_name = aws_s3_bucket.static_content.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.site.cloudfront_access_identity_path
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Requests should be coming from Europe or North America
  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "IE"]
    }
  }

  tags = {
    Environment = "prod"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "cdn_fqdn" {
  value = aws_cloudfront_distribution.site.domain_name
}
