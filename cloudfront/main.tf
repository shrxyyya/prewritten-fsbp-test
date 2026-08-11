terraform {
  required_version = ">= 1.15.0"

  cloud {

    organization = "nagateja-test-org"

    workspaces {
      name = "provider-test"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "origin" {
  bucket = "example-cloudfront-origin"
}

resource "aws_s3_bucket" "logs" {
  bucket = "example-cloudfront-logs"
}

resource "aws_cloudfront_origin_access_control" "example" {
  name                              = "example-oac"
  origin_access_control_origin_type = "s3"

  # cloudfront-s3-origin-access-control-enabled: must be "always" + "sigv4"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}

resource "aws_cloudfront_key_group" "example" {
  name  = "example-key-group"
  items = [aws_cloudfront_public_key.example.id]
}

resource "aws_cloudfront_public_key" "example" {
  name        = "example-public-key"
  encoded_key = file("${path.module}/public_key.pem")
}

resource "aws_wafv2_web_acl" "example" {
  name  = "example-waf-acl"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "example-waf-acl"
    sampled_requests_enabled   = true
  }
}

resource "aws_cloudfront_distribution" "example" {
  enabled             = true
  # cloudfront-default-root-object-configured: S3 origin needs a default root object
  default_root_object = "index.html"
  # cloudfront-associated-with-waf: reference the WAF ACL
  web_acl_id          = aws_wafv2_web_acl.example.arn

  # S3 origin with OAC (cloudfront-s3-origin-access-control-enabled,
  # cloudfront-s3-origin-non-existent-bucket, cloudfront-default-root-object-configured)
  origin {
    domain_name              = aws_s3_bucket.origin.bucket_regional_domain_name
    origin_id                = "s3-primary"
    origin_access_control_id = aws_cloudfront_origin_access_control.example.id
  }

  # Second S3 origin for origin failover (cloudfront-origin-failover-enabled)
  origin {
    domain_name              = aws_s3_bucket.logs.bucket_regional_domain_name
    origin_id                = "s3-failover"
    origin_access_control_id = aws_cloudfront_origin_access_control.example.id
  }

  # cloudfront-origin-failover-enabled: origin group with primary + failover members
  origin_group {
    origin_id = "s3-origin-group"

    failover_criteria {
      status_codes = [500, 502, 503, 504]
    }

    member {
      origin_id = "s3-primary"
    }
    member {
      origin_id = "s3-failover"
    }
  }

  default_cache_behavior {
    # Target the origin group for failover (cloudfront-origin-failover-enabled)
    target_origin_id = "s3-origin-group"

    # cloudfront-viewer-policy-https & cloudfront-traffic-to-origin-encrypted:
    # no "allow-all" viewer protocol
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    # cloudfront-distribution-key-group-enabled: trusted_key_groups (not trusted_signers)
    trusted_key_groups = [aws_cloudfront_key_group.example.id]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # cloudfront-accesslogs-enabled: logging_config with valid S3 bucket
  logging_config {
    bucket = aws_s3_bucket.logs.bucket_domain_name
    prefix = "cloudfront-logs/"
  }

  # cloudfront-custom-ssl-certificate & cloudfront-sni-enabled & cloudfront-ssl-policy-check:
  # custom ACM cert, sni-only, TLSv1.2_2021
  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/example"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
