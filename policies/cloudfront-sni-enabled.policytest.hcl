# Copyright IBM Corp. 2026

policytest {
  targets = [
    "cloudfront-sni-enabled.policy.hcl"
    ]
}

# PASS: Distribution using CloudFront default certificate
resource "aws_cloudfront_distribution" "pass_default_certificate" {
  attrs = {
    enabled = true
    viewer_certificate = [
      {
        cloudfront_default_certificate = true
        minimum_protocol_version      = "TLSv1"
      }
    ]
  }
}

# PASS: Distribution with ACM certificate and SNI
resource "aws_cloudfront_distribution" "pass_acm_with_sni" {
  attrs = {
    enabled = true
    viewer_certificate = [
      {
        acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
        ssl_support_method       = "sni-only"
        minimum_protocol_version = "TLSv1.2_2021"
      }
    ]
  }
}

# PASS: Distribution with IAM certificate and SNI
resource "aws_cloudfront_distribution" "pass_iam_with_sni" {
  attrs = {
    enabled = true
    viewer_certificate = [
      {
        iam_certificate_id       = "ASCACKCEVSQ6C2EXAMPLE"
        ssl_support_method       = "sni-only"
        minimum_protocol_version = "TLSv1.2_2021"
      }
    ]
  }
}

# FAIL: Distribution with ACM certificate using VIP (dedicated IP)
resource "aws_cloudfront_distribution" "fail_acm_with_vip" {
  expect_failure = true
  attrs = {
    enabled = true
    viewer_certificate = [
      {
        acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
        ssl_support_method       = "vip"
        minimum_protocol_version = "TLSv1.2_2021"
      }
    ]
  }
}

# FAIL: Distribution with IAM certificate using static-ip
resource "aws_cloudfront_distribution" "fail_iam_with_static_ip" {
  expect_failure = true
  attrs = {
    enabled = true
    viewer_certificate = [
      {
        iam_certificate_id       = "ASCACKCEVSQ6C2EXAMPLE"
        ssl_support_method       = "static-ip"
        minimum_protocol_version = "TLSv1.2_2021"
      }
    ]
  }
}

# FAIL: Distribution with ACM certificate but no ssl_support_method
resource "aws_cloudfront_distribution" "fail_acm_no_ssl_method" {
  expect_failure = true
  attrs = {
    enabled = true
    viewer_certificate = [
      {
        acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
        minimum_protocol_version = "TLSv1.2_2021"
      }
    ]
  }
}

# SKIP: Disabled distribution should not be evaluated (filtered out)
resource "aws_cloudfront_distribution" "skip_disabled_distribution" {
  attrs = {
    enabled = false
    viewer_certificate = [
      {
        acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
        ssl_support_method  = "vip"
      }
    ]
  }
}