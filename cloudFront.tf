resource "aws_cloudfront_origin_access_identity" "cloudfront_OAI" {
    comment = "cloudfront origin access identicty for finBloom frontend"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.frontend_s3_bucket.bucket_regional_domain_name
    origin_id = aws_s3_bucket.frontend_s3_bucket.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_OAI.cloudfront_access_identity_path
    }
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

    

  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id = aws_s3_bucket.frontend_s3_bucket.id

    forwarded_values {
      query_string = false
        
      cookies  {
        forward = "none"
      }
    }
  }
  
    viewer_certificate {
      acm_certificate_arn = aws_acm_certificate.finBloom_cert.arn
      ssl_support_method = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }

    aliases = [var.domain]

    restrictions {
      geo_restriction {
        restriction_type = "none"
      }
    }

    tags = {
      name = "S3 cloudfront distribution"
      Environment = "Dev"
    }
}

