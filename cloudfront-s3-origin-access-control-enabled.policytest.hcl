# Copyright IBM Corp. 2026

policytest {
  targets = [
    "cloudfront-s3-origin-access-control-enabled.policy.hcl"
  ]
}

# Test 1: PASS - CloudFront distribution with S3 origin that has OAC configured
resource "aws_cloudfront_distribution" "pass_s3_origin_with_oac" {
  attrs = {
    origin = [
      {
        domain_name = "my-bucket.s3.amazonaws.com"
        origin_id = "S3-my-bucket"
        origin_access_control_id = "E1234567890ABC"
      }
    ]
    enabled = true
  }
}

# Test 2: FAIL - CloudFront distribution with S3 origin missing OAC
resource "aws_cloudfront_distribution" "fail_s3_origin_without_oac" {
  expect_failure = true
  attrs = {
    origin = [
      {
        domain_name = "my-bucket.s3.amazonaws.com"
        origin_id = "S3-my-bucket"
      }
    ]
    enabled = true
  }
}

# Test 3: PASS - CloudFront distribution with multiple S3 origins all having OAC
resource "aws_cloudfront_distribution" "pass_multiple_s3_origins_all_with_oac" {
  attrs = {
    origin = [
      {
        domain_name = "bucket1.s3.amazonaws.com"
        origin_id = "S3-bucket1"
        origin_access_control_id = "E1234567890ABC"
      },
      {
        domain_name = "bucket2.s3.us-east-1.amazonaws.com"
        origin_id = "S3-bucket2"
        origin_access_control_id = "E0987654321XYZ"
      }
    ]
    enabled = true
  }
}

# Test 4: FAIL - CloudFront distribution with multiple S3 origins, only some with OAC
resource "aws_cloudfront_distribution" "fail_multiple_s3_origins_partial_oac" {
  expect_failure = true
  attrs = {
    origin = [
      {
        domain_name = "bucket1.s3.amazonaws.com"
        origin_id = "S3-bucket1"
        origin_access_control_id = "E1234567890ABC"
      },
      {
        domain_name = "bucket2.s3.us-west-2.amazonaws.com"
        origin_id = "S3-bucket2"
      }
    ]
    enabled = true
  }
}

# Test 5: PASS - CloudFront distribution with only custom (non-S3) origins
resource "aws_cloudfront_distribution" "pass_custom_origin_only" {
  attrs = {
    origin = [
      {
        domain_name = "example.com"
        origin_id = "custom-origin"
        custom_origin_config = {
          http_port = 80
          https_port = 443
          origin_protocol_policy = "https-only"
        }
      }
    ]
    enabled = true
  }
}

# Test 6: PASS - CloudFront distribution with S3 website endpoint origin
resource "aws_cloudfront_distribution" "pass_s3_website_origin_with_oac" {
  attrs = {
    origin = [
      {
        domain_name = "my-bucket.s3-website-us-east-1.amazonaws.com"
        origin_id = "S3-website"
        origin_access_control_id = "E1234567890ABC"
      }
    ]
    enabled = true
  }
}

# Test 7: PASS - OAC with correct configuration
resource "aws_cloudfront_origin_access_control" "pass_oac_correct_config" {
  attrs = {
    name = "example-oac"
    signing_behavior = "always"
    signing_protocol = "sigv4"
    origin_access_control_origin_type = "s3"
  }
}

# Test 8: FAIL - OAC with incorrect signing_behavior
resource "aws_cloudfront_origin_access_control" "fail_oac_wrong_signing_behavior" {
  expect_failure = true
  attrs = {
    name = "example-oac"
    signing_behavior = "never"
    signing_protocol = "sigv4"
    origin_access_control_origin_type = "s3"
  }
}

# Test 9: FAIL - OAC with incorrect signing_protocol
resource "aws_cloudfront_origin_access_control" "fail_oac_wrong_signing_protocol" {
  expect_failure = true
  attrs = {
    name = "example-oac"
    signing_behavior = "always"
    signing_protocol = "sigv2"
    origin_access_control_origin_type = "s3"
  }
}

# Test 10: PASS (filtered out) - non-S3 OAC types are out of scope for CloudFront.13
resource "aws_cloudfront_origin_access_control" "pass_oac_non_s3_origin_type" {
  attrs = {
    name = "example-oac"
    signing_behavior = "always"
    signing_protocol = "sigv4"
    origin_access_control_origin_type = "lambda"
  }
}

# Note: S3 bucket policy tests removed because tfpolicy does not support string pattern matching
# (no regex, startswith, endswith, or substring functions available).
# The policy document is a JSON string that cannot be parsed without these functions.

# Test 11: FAIL - Distribution with null origin list (no origins is a violation)
resource "aws_cloudfront_distribution" "fail_null_origin" {
  expect_failure = true
  attrs = {
    enabled = true
    origin  = null
  }
}

# Test 12: FAIL - Distribution with empty origin list (no origins is a violation)
resource "aws_cloudfront_distribution" "fail_empty_origin" {
  expect_failure = true
  attrs = {
    enabled = true
    origin  = []
  }
}

# Test 13: FAIL - S3 origin where origin_access_control_id is explicitly null
resource "aws_cloudfront_distribution" "fail_s3_origin_oac_id_null" {
  expect_failure = true
  attrs = {
    origin = [
      {
        domain_name              = "my-bucket.s3.amazonaws.com"
        origin_id                = "S3-my-bucket-null-oac"
        origin_access_control_id = null
      }
    ]
    enabled = true
  }
}

# Test 14: FAIL - S3 origin where origin_access_control_id is an empty string
resource "aws_cloudfront_distribution" "fail_s3_origin_oac_id_empty_string" {
  expect_failure = true
  attrs = {
    origin = [
      {
        domain_name              = "my-bucket.s3.amazonaws.com"
        origin_id                = "S3-my-bucket-empty-oac"
        origin_access_control_id = ""
      }
    ]
    enabled = true
  }
}

# Test 15: PASS - Mixed origins: one custom (non-S3) and one S3 with OAC
resource "aws_cloudfront_distribution" "pass_mixed_custom_and_s3_with_oac" {
  attrs = {
    origin = [
      {
        domain_name = "api.example.com"
        origin_id   = "custom-api"
        custom_origin_config = {
          http_port              = 80
          https_port             = 443
          origin_protocol_policy = "https-only"
        }
      },
      {
        domain_name              = "my-bucket.s3.amazonaws.com"
        origin_id                = "S3-my-bucket"
        origin_access_control_id = "E1234567890ABC"
      }
    ]
    enabled = true
  }
}

# Test 16: FAIL - Mixed origins: one custom (non-S3) and one S3 without OAC
resource "aws_cloudfront_distribution" "fail_mixed_custom_and_s3_without_oac" {
  expect_failure = true
  attrs = {
    origin = [
      {
        domain_name = "api.example.com"
        origin_id   = "custom-api"
        custom_origin_config = {
          http_port              = 80
          https_port             = 443
          origin_protocol_policy = "https-only"
        }
      },
      {
        domain_name = "my-bucket.s3.amazonaws.com"
        origin_id   = "S3-my-bucket-no-oac"
      }
    ]
    enabled = true
  }
}

# Test 17: FAIL - OAC with null signing_behavior
resource "aws_cloudfront_origin_access_control" "fail_oac_null_signing_behavior" {
  expect_failure = true
  attrs = {
    name                               = "oac-null-signing-behavior"
    signing_behavior                   = null
    signing_protocol                   = "sigv4"
    origin_access_control_origin_type  = "s3"
  }
}

# Test 18: FAIL - OAC with null signing_protocol
resource "aws_cloudfront_origin_access_control" "fail_oac_null_signing_protocol" {
  expect_failure = true
  attrs = {
    name                               = "oac-null-signing-protocol"
    signing_behavior                   = "always"
    signing_protocol                   = null
    origin_access_control_origin_type  = "s3"
  }
}

# Test 19: FAIL - OAC with both signing_behavior and signing_protocol missing
resource "aws_cloudfront_origin_access_control" "fail_oac_missing_both_signing_attrs" {
  expect_failure = true
  attrs = {
    name                               = "oac-missing-signing-attrs"
    origin_access_control_origin_type  = "s3"
  }
}