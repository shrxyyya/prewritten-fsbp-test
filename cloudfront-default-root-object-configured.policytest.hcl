# Copyright IBM Corp. 2026

policytest {
    targets = [
        "cloudfront-default-root-object-configured.policy.hcl"
    ]
}

# Test 1: PASS - Distribution with S3 origin and default root object configured
resource "aws_cloudfront_distribution" "pass_s3_origin_with_default_root_object" {
  attrs = {
    default_root_object = "index.html"
    origin = [
      {
        domain_name = "example-bucket.s3.amazonaws.com"
        origin_id   = "s3Origin"
        s3_origin_config = {
          origin_access_identity = "origin-access-identity/cloudfront/EXAMPLE"
        }
      }
    ]
  }
}

# Test 2: FAIL - Distribution with S3 origin and missing default root object
resource "aws_cloudfront_distribution" "fail_s3_origin_missing_default_root_object" {
  expect_failure = true
  attrs = {
    origin = [
      {
        domain_name = "example-bucket.s3.amazonaws.com"
        origin_id   = "s3Origin"
        s3_origin_config = {
          origin_access_identity = "origin-access-identity/cloudfront/EXAMPLE"
        }
      }
    ]
  }
}

# Test 3: PASS - Distribution with custom origin and no default root object
resource "aws_cloudfront_distribution" "pass_custom_origin_no_default_root_object" {
  attrs = {
    origin = [
      {
        domain_name = "app.example.com"
        origin_id   = "customOrigin"
        custom_origin_config = {
          http_port              = 80
          https_port             = 443
          origin_protocol_policy = "https-only"
        }
      }
    ]
  }
}

# Test 4: PASS - Distribution with origin access control id and default root object configured
resource "aws_cloudfront_distribution" "pass_oac_s3_origin_with_default_root_object" {
  attrs = {
    default_root_object = "home.html"
    origin = [
      {
        domain_name              = "example-bucket.s3.amazonaws.com"
        origin_id                = "s3OriginWithOac"
        origin_access_control_id = "E2ABCDEFG12345"
      }
    ]
  }
}

# Test 5: FAIL - Distribution with origin access control id and empty default root object
resource "aws_cloudfront_distribution" "fail_oac_s3_origin_empty_default_root_object" {
  expect_failure = true
  attrs = {
    default_root_object = ""
    origin = [
      {
        domain_name              = "example-bucket.s3.amazonaws.com"
        origin_id                = "s3OriginWithOac"
        origin_access_control_id = "E2ABCDEFG12345"
      }
    ]
  }
}

