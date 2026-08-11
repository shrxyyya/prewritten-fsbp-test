# Copyright IBM Corp. 2026

policytest {
  targets = [
    "cloudfront-distribution-key-group-enabled.policy.hcl"
  ]
}
# Pass: No authentication configured
resource "aws_cloudfront_distribution" "pass_no_authentication" {
  attrs = {
    default_cache_behavior = [
      {
        target_origin_id = "S3-example"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        forwarded_values = [
          {
            query_string = false
            cookies = [{ forward = "none" }]
          }
        ]
      }
    ]
  }
}

# Pass: Using trusted_key_groups in default_cache_behavior
resource "aws_cloudfront_distribution" "pass_trusted_key_groups_default" {
  attrs = {
    default_cache_behavior = [
      {
        target_origin_id = "S3-example"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        trusted_key_groups = ["key-group-1", "key-group-2"]
        forwarded_values = [
          {
            query_string = false
            cookies = [{ forward = "none" }]
          }
        ]
      }
    ]
  }
}

# Pass: Using trusted_key_groups in ordered_cache_behavior
resource "aws_cloudfront_distribution" "pass_trusted_key_groups_ordered" {
  attrs = {
    default_cache_behavior = [
      {
        target_origin_id = "S3-example"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        forwarded_values = [
          {
            query_string = false
            cookies = [{ forward = "none" }]
          }
        ]
      }
    ]
    ordered_cache_behavior = [
      {
        path_pattern = "/private/*"
        target_origin_id = "S3-example"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        trusted_key_groups = ["key-group-1"]
        forwarded_values = [
          {
            query_string = false
            cookies = [{ forward = "none" }]
          }
        ]
      }
    ]
  }
}

# Fail: Using deprecated trusted_signers in default_cache_behavior
resource "aws_cloudfront_distribution" "fail_trusted_signers_default" {
  expect_failure = true
  attrs = {
    default_cache_behavior = [
      {
        target_origin_id = "S3-example"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        trusted_signers = ["self"]
        forwarded_values = [
          {
            query_string = false
            cookies = [{ forward = "none" }]
          }
        ]
      }
    ]
  }
}

# Fail: Using deprecated trusted_signers in ordered_cache_behavior
resource "aws_cloudfront_distribution" "fail_trusted_signers_ordered" {
  expect_failure = true
  attrs = {
    default_cache_behavior = [
      {
        target_origin_id = "S3-example"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        forwarded_values = [
          {
            query_string = false
            cookies = [{ forward = "none" }]
          }
        ]
      }
    ]
    ordered_cache_behavior = [
      {
        path_pattern = "/private/*"
        target_origin_id = "S3-example"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        trusted_signers = ["123456789012"]
        forwarded_values = [
          {
            query_string = false
            cookies = [{ forward = "none" }]
          }
        ]
      }
    ]
  }
}

# Fail: Using both trusted_signers and trusted_key_groups
resource "aws_cloudfront_distribution" "fail_both_signers_and_key_groups" {
  expect_failure = true
  attrs = {
    default_cache_behavior = [
      {
        target_origin_id = "S3-example"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        trusted_signers = ["self"]
        trusted_key_groups = ["key-group-1"]
        forwarded_values = [
          {
            query_string = false
            cookies = [{ forward = "none" }]
          }
        ]
      }
    ]
  }
}