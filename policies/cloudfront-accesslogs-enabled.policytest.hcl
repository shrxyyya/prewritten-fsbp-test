# Copyright IBM Corp. 2026

policytest {
  targets = [
    "cloudfront-accesslogs-enabled.policy.hcl"
  ]
}
# Pass case: Distribution with valid logging configuration
resource "aws_cloudfront_distribution" "pass_with_valid_logging_config" {
  attrs = {
    enabled = true
    logging_config = [
      {
        bucket          = "myawslogbucket.s3.amazonaws.com"
        prefix          = "cloudfront/"
        include_cookies = false
      }
    ]
    origin = [
      {
        domain_name = "example.com"
        origin_id   = "example"
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id       = "example"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods        = ["GET", "HEAD"]
        cached_methods         = ["GET", "HEAD"]
        forwarded_values = [
          {
            query_string = false
            cookies = [
              {
                forward = "none"
              }
            ]
          }
        ]
      }
    ]
    restrictions = [
      {
        geo_restriction = [
          {
            restriction_type = "none"
          }
        ]
      }
    ]
    viewer_certificate = [
      {
        cloudfront_default_certificate = true
      }
    ]
  }
}

# Pass case: Distribution with minimal logging config (bucket only)
resource "aws_cloudfront_distribution" "pass_with_minimal_logging_config" {
  attrs = {
    enabled = true
    logging_config = [
      {
        bucket = "logs.s3.amazonaws.com"
      }
    ]
    origin = [
      {
        domain_name = "example.com"
        origin_id   = "example"
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id       = "example"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods        = ["GET", "HEAD"]
        cached_methods         = ["GET", "HEAD"]
        forwarded_values = [
          {
            query_string = false
            cookies = [
              {
                forward = "none"
              }
            ]
          }
        ]
      }
    ]
    restrictions = [
      {
        geo_restriction = [
          {
            restriction_type = "none"
          }
        ]
      }
    ]
    viewer_certificate = [
      {
        cloudfront_default_certificate = true
      }
    ]
  }
}

# Fail case: Distribution without logging_config block
resource "aws_cloudfront_distribution" "fail_without_logging_config" {
  expect_failure = true
  attrs = {
    enabled = true
    origin = [
      {
        domain_name = "example.com"
        origin_id   = "example"
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id       = "example"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods        = ["GET", "HEAD"]
        cached_methods         = ["GET", "HEAD"]
        forwarded_values = [
          {
            query_string = false
            cookies = [
              {
                forward = "none"
              }
            ]
          }
        ]
      }
    ]
    restrictions = [
      {
        geo_restriction = [
          {
            restriction_type = "none"
          }
        ]
      }
    ]
    viewer_certificate = [
      {
        cloudfront_default_certificate = true
      }
    ]
  }
}

# Fail case: Distribution with empty bucket in logging_config
resource "aws_cloudfront_distribution" "fail_with_empty_bucket" {
  expect_failure = true
  attrs = {
    enabled = true
    logging_config = [
      {
        bucket = ""
      }
    ]
    origin = [
      {
        domain_name = "example.com"
        origin_id   = "example"
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id       = "example"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods        = ["GET", "HEAD"]
        cached_methods         = ["GET", "HEAD"]
        forwarded_values = [
          {
            query_string = false
            cookies = [
              {
                forward = "none"
              }
            ]
          }
        ]
      }
    ]
    restrictions = [
      {
        geo_restriction = [
          {
            restriction_type = "none"
          }
        ]
      }
    ]
    viewer_certificate = [
      {
        cloudfront_default_certificate = true
      }
    ]
  }
}

# Pass case: Disabled distribution without logging (should be filtered out)
resource "aws_cloudfront_distribution" "pass_disabled_distribution_filtered" {
  attrs = {
    enabled = false
    origin = [
      {
        domain_name = "example.com"
        origin_id   = "example"
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id       = "example"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods        = ["GET", "HEAD"]
        cached_methods         = ["GET", "HEAD"]
        forwarded_values = [
          {
            query_string = false
            cookies = [
              {
                forward = "none"
              }
            ]
          }
        ]
      }
    ]
    restrictions = [
      {
        geo_restriction = [
          {
            restriction_type = "none"
          }
        ]
      }
    ]
    viewer_certificate = [
      {
        cloudfront_default_certificate = true
      }
    ]
  }
}