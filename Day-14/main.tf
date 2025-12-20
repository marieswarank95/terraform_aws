#S3 bucket creation
resource "aws_s3_bucket" "static_web_bucket" {
    bucket = var.bucket_name
    tags = var.tags
    # lifecycle {
    #     ignore_changes = [website]
    # }
}

#To enable static website hosting
resource "aws_s3_bucket_website_configuration" "s3_static_web_config" {
    bucket = aws_s3_bucket.static_web_bucket.id
    index_document {
        suffix = "index.html"
    }
}

#S3 bucket policy creation
resource "aws_s3_bucket_policy" "static_web_bucket_policy" {
    bucket = aws_s3_bucket.static_web_bucket.id
    policy = jsonencode(
    {
  "Version":"2012-10-17",		 	 	 
  "Statement": [
    {
      "Sid": "AllowCloudFrontServicePrincipalReadOnly",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudfront.amazonaws.com"
      },
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.static_web_bucket.arn}/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": aws_cloudfront_distribution.s3_distribution.arn
        }
      }
    }
  ]
}
)
}

#object upload into S3 bucket
resource "aws_s3_object" "object" {
    for_each = fileset("${path.module}/web", "*")
    bucket = aws_s3_bucket.static_web_bucket.id
    key = each.key
    source = "${path.module}/web/${each.key}"
    content_type = lookup({
        html = "text/html",
        css = "text/css",
        js = "text/javascript"
    }, element(split(".", each.key), -1), "text")
}

#cloudfront Origin Access Control
resource "aws_cloudfront_origin_access_control" "cf_oac" {
  name                              = "${aws_s3_bucket.static_web_bucket.id}-oac"
  description                       = "testing"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#cloudfront distribution creation
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.static_web_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cf_oac.id
    origin_id                = aws_s3_bucket.static_web_bucket.id
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "This CF distribution for Terraform Practice"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.static_web_bucket.id
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
  tags = var.tags
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}