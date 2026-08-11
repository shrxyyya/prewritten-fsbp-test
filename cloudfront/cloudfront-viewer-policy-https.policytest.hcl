# Copyright IBM Corp. 2026

policytest {
    targets = [
        "cloudfront-viewer-policy-https.policy.hcl"
    ]
}

# Test 1: FAIL - default cache behavior allows all protocols
resource "aws_cloudfront_distribution" "fail_default_cache_behavior_allow_all" {
  expect_failure = true
  attrs = {
    default_cache_behavior = [
      {
        viewer_protocol_policy = "allow-all"
      }
    ]
  }
}

# Test 2: PASS - default cache behavior redirects to HTTPS
resource "aws_cloudfront_distribution" "pass_default_cache_behavior_redirect_to_https" {
  attrs = {
    default_cache_behavior = [
      {
        viewer_protocol_policy = "redirect-to-https"
      }
    ]
  }
}

# Test 3: FAIL - ordered cache behavior allows all protocols
resource "aws_cloudfront_distribution" "fail_ordered_cache_behavior_allow_all" {
  expect_failure = true
  attrs = {
    default_cache_behavior = [
      {
        viewer_protocol_policy = "https-only"
      }
    ]
    ordered_cache_behavior = [
      {
        viewer_protocol_policy = "allow-all"
      }
    ]
  }
}

# Test 4: PASS - ordered cache behavior uses HTTPS only
resource "aws_cloudfront_distribution" "pass_ordered_cache_behavior_https_only" {
  attrs = {
    default_cache_behavior = [
      {
        viewer_protocol_policy = "redirect-to-https"
      }
    ]
    ordered_cache_behavior = [
      {
        viewer_protocol_policy = "https-only"
      }
    ]
  }
}

# Test 5: PASS - missing ordered cache behavior and secure default cache behavior
resource "aws_cloudfront_distribution" "pass_missing_ordered_cache_behavior" {
  attrs = {
    default_cache_behavior = [
      {
        viewer_protocol_policy = "https-only"
      }
    ]
  }
}

