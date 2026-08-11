# Copyright IBM Corp. 2026

policytest {
  targets = [
    "cloudfront-origin-lambda-url-oac-enabled.policy.hcl"
  ]
}

# ============================================================================
# Test 0: CloudFront distribution with non-Lambda custom origin (PASS)
# ============================================================================
resource "aws_cloudfront_distribution" "non_lambda_custom_origin_pass" {
  attrs = {
    enabled = true
    origin = [
      {
        domain_name = "api.example.com"
        origin_id   = "custom-origin-1"
        custom_origin_config = [
          {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols   = ["TLSv1.2"]
          }
        ]
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id       = "custom-origin-1"
        viewer_protocol_policy = "redirect-to-https"
      }
    ]
  }
}
# ============================================================================
# Test 1: CloudFront distribution with Lambda origin + OAC (PASS)
# ============================================================================
resource "aws_cloudfront_distribution" "lambda_with_oac_pass" {
  attrs = {
    enabled = true
    origin = [
      {
        domain_name              = "abc123.lambda-url.us-east-1.on.aws"
        origin_id                = "lambda-origin-1"
        origin_access_control_id = "E1234567890ABC"
        custom_origin_config = [
          {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols   = ["TLSv1.2"]
          }
        ]
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id       = "lambda-origin-1"
        viewer_protocol_policy = "redirect-to-https"
      }
    ]
  }
}

# ============================================================================
# Test 2: CloudFront distribution with Lambda origin WITHOUT OAC (FAIL)
# ============================================================================
resource "aws_cloudfront_distribution" "lambda_without_oac_fail" {
  expect_failure = true
  attrs = {
    enabled = true
    origin = [
      {
        domain_name = "xyz789.lambda-url.us-west-2.on.aws"
        origin_id   = "lambda-origin-2"
        # origin_access_control_id is missing - should fail
        custom_origin_config = [
          {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols   = ["TLSv1.2"]
          }
        ]
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id       = "lambda-origin-2"
        viewer_protocol_policy = "redirect-to-https"
      }
    ]
  }
}

# ============================================================================
# Test 3: CloudFront distribution with multiple origins, all Lambda with OAC (PASS)
# ============================================================================
resource "aws_cloudfront_distribution" "multiple_lambda_with_oac_pass" {
  attrs = {
    enabled = true
    origin = [
      {
        domain_name              = "func1.lambda-url.us-east-1.on.aws"
        origin_id                = "lambda-origin-1"
        origin_access_control_id = "E1111111111AAA"
        custom_origin_config = [
          {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols   = ["TLSv1.2"]
          }
        ]
      },
      {
        domain_name              = "func2.lambda-url.us-east-1.on.aws"
        origin_id                = "lambda-origin-2"
        origin_access_control_id = "E2222222222BBB"
        custom_origin_config = [
          {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols   = ["TLSv1.2"]
          }
        ]
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id       = "lambda-origin-1"
        viewer_protocol_policy = "redirect-to-https"
      }
    ]
  }
}

# ============================================================================
# Test 4: CloudFront distribution with multiple Lambda origins, one missing OAC (FAIL)
# ============================================================================
resource "aws_cloudfront_distribution" "multiple_lambda_one_missing_oac_fail" {
  expect_failure = true
  attrs = {
    enabled = true
    origin = [
      {
        domain_name              = "func1.lambda-url.us-east-1.on.aws"
        origin_id                = "lambda-origin-1"
        origin_access_control_id = "E1111111111AAA"
        custom_origin_config = [
          {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols   = ["TLSv1.2"]
          }
        ]
      },
      {
        domain_name = "func2.lambda-url.us-east-1.on.aws"
        origin_id   = "lambda-origin-2"
        # origin_access_control_id is missing - should fail
        custom_origin_config = [
          {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols   = ["TLSv1.2"]
          }
        ]
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id       = "lambda-origin-1"
        viewer_protocol_policy = "redirect-to-https"
      }
    ]
  }
}

# ============================================================================
# Test 5: CloudFront distribution with only S3 origins (PASS - not applicable)
# ============================================================================
resource "aws_cloudfront_distribution" "s3_only_pass" {
  attrs = {
    enabled = true
    origin = [
      {
        domain_name              = "my-bucket.s3.amazonaws.com"
        origin_id                = "s3-origin-1"
        origin_access_control_id = "E3333333333CCC"
        s3_origin_config = [
          {
            origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
          }
        ]
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id       = "s3-origin-1"
        viewer_protocol_policy = "redirect-to-https"
      }
    ]
  }
}

# ============================================================================
# Test 6: CloudFront distribution with no origins (PASS - filtered out)
# ============================================================================
resource "aws_cloudfront_distribution" "no_origins_pass" {
  attrs = {
    enabled = true
    origin  = []
    default_cache_behavior = [
      {
        target_origin_id       = "dummy"
        viewer_protocol_policy = "redirect-to-https"
      }
    ]
  }
}

# ============================================================================
# Test 7: CloudFront distribution with mixed origins (S3 + Lambda with OAC) (PASS)
# ============================================================================
resource "aws_cloudfront_distribution" "mixed_origins_pass" {
  attrs = {
    enabled = true
    origin = [
      {
        domain_name              = "my-bucket.s3.amazonaws.com"
        origin_id                = "s3-origin"
        origin_access_control_id = "E4444444444DDD"
        s3_origin_config = [
          {
            origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
          }
        ]
      },
      {
        domain_name              = "func.lambda-url.us-east-1.on.aws"
        origin_id                = "lambda-origin"
        origin_access_control_id = "E5555555555EEE"
        custom_origin_config = [
          {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols   = ["TLSv1.2"]
          }
        ]
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id       = "s3-origin"
        viewer_protocol_policy = "redirect-to-https"
      }
    ]
  }
}
