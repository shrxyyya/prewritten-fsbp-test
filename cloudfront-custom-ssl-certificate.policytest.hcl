# Copyright IBM Corp. 2026

policytest {
  targets = [
    "cloudfront-custom-ssl-certificate.policy.hcl"
    ]
}

# PASS: CloudFront distribution with ACM certificate configured
resource "aws_cloudfront_distribution" "pass_acm_certificate" {
  attrs = {
    viewer_certificate = [
      {
        acm_certificate_arn            = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
        ssl_support_method             = "sni-only"
        minimum_protocol_version       = "TLSv1.2_2021"
        cloudfront_default_certificate = false
      }
    ]
    enabled = true
    aliases = ["example.com", "www.example.com"]
  }
}

# PASS: CloudFront distribution with IAM certificate configured
resource "aws_cloudfront_distribution" "pass_iam_certificate" {
  attrs = {
    viewer_certificate = [
      {
        iam_certificate_id             = "ASCACKCEVSQ6C2EXAMPLE"
        ssl_support_method             = "sni-only"
        minimum_protocol_version       = "TLSv1.2_2021"
        cloudfront_default_certificate = false
      }
    ]
    enabled = true
    aliases = ["example.org"]
  }
}

# FAIL: CloudFront distribution using default certificate
resource "aws_cloudfront_distribution" "fail_default_certificate" {
  expect_failure = true
  attrs = {
    viewer_certificate = [
      {
        cloudfront_default_certificate = true
        minimum_protocol_version       = "TLSv1"
      }
    ]
    enabled = true
  }
}

# FAIL: CloudFront distribution with no viewer_certificate block
resource "aws_cloudfront_distribution" "fail_no_viewer_certificate" {
  expect_failure = true
  attrs = {
    enabled = true
  }
}

# FAIL: CloudFront distribution with viewer_certificate but no custom certificate
resource "aws_cloudfront_distribution" "fail_no_custom_certificate" {
  expect_failure = true
  attrs = {
    viewer_certificate = [
      {
        ssl_support_method       = "sni-only"
        minimum_protocol_version = "TLSv1.2_2021"
      }
    ]
    enabled = true
  }
}