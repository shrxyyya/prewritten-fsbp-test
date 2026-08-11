# Copyright IBM Corp. 2026

policytest {
  targets = [
    "cloudfront-associated-with-waf.policy.hcl"
  ]
}

# Test 1: Pass - CloudFront distribution with WAFv2 web ACL ARN configured
resource "aws_cloudfront_distribution" "pass_with_wafv2_acl" {
  attrs = {
    web_acl_id = "arn:aws:wafv2:us-east-1:123456789012:global/webacl/example/a1b2c3d4-5678-90ab-cdef-EXAMPLE11111"
    enabled = true
    origin = [{
      domain_name = "example.com"
      origin_id = "example"
    }]
    default_cache_behavior = [{
      target_origin_id = "example"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods = ["GET", "HEAD"]
      cached_methods = ["GET", "HEAD"]
      forwarded_values = [{
        query_string = false
        cookies = [{
          forward = "none"
        }]
      }]
    }]
    restrictions = [{
      geo_restriction = [{
        restriction_type = "none"
      }]
    }]
    viewer_certificate = [{
      cloudfront_default_certificate = true
    }]
  }
}

# Test 2: Pass - CloudFront distribution with WAF Classic web ACL ID configured
resource "aws_cloudfront_distribution" "pass_with_waf_classic_acl" {
  attrs = {
    web_acl_id = "a1b2c3d4-5678-90ab-cdef-EXAMPLE11111"
    enabled = true
    origin = [{
      domain_name = "example.com"
      origin_id = "example"
    }]
    default_cache_behavior = [{
      target_origin_id = "example"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods = ["GET", "HEAD"]
      cached_methods = ["GET", "HEAD"]
      forwarded_values = [{
        query_string = false
        cookies = [{
          forward = "none"
        }]
      }]
    }]
    restrictions = [{
      geo_restriction = [{
        restriction_type = "none"
      }]
    }]
    viewer_certificate = [{
      cloudfront_default_certificate = true
    }]
  }
}

# Test 3: Fail - CloudFront distribution without web_acl_id configured
resource "aws_cloudfront_distribution" "fail_without_web_acl_id" {
  expect_failure = true
  attrs = {
    enabled = true
    origin = [{
      domain_name = "example.com"
      origin_id = "example"
    }]
    default_cache_behavior = [{
      target_origin_id = "example"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods = ["GET", "HEAD"]
      cached_methods = ["GET", "HEAD"]
      forwarded_values = [{
        query_string = false
        cookies = [{
          forward = "none"
        }]
      }]
    }]
    restrictions = [{
      geo_restriction = [{
        restriction_type = "none"
      }]
    }]
    viewer_certificate = [{
      cloudfront_default_certificate = true
    }]
  }
}

# Test 4: Fail - CloudFront distribution with empty web_acl_id
resource "aws_cloudfront_distribution" "fail_with_empty_web_acl_id" {
  expect_failure = true
  attrs = {
    web_acl_id = ""
    enabled = true
    origin = [{
      domain_name = "example.com"
      origin_id = "example"
    }]
    default_cache_behavior = [{
      target_origin_id = "example"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods = ["GET", "HEAD"]
      cached_methods = ["GET", "HEAD"]
      forwarded_values = [{
        query_string = false
        cookies = [{
          forward = "none"
        }]
      }]
    }]
    restrictions = [{
      geo_restriction = [{
        restriction_type = "none"
      }]
    }]
    viewer_certificate = [{
      cloudfront_default_certificate = true
    }]
  }
}

# Test 5: Fail - CloudFront distribution with web_acl_id explicitly set to null
resource "aws_cloudfront_distribution" "fail_with_null_web_acl_id" {
  expect_failure = true
  attrs = {
    web_acl_id = null
    enabled = true
    origin = [{
      domain_name = "example.com"
      origin_id = "example"
    }]
    default_cache_behavior = [{
      target_origin_id = "example"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods = ["GET", "HEAD"]
      cached_methods = ["GET", "HEAD"]
      forwarded_values = [{
        query_string = false
        cookies = [{
          forward = "none"
        }]
      }]
    }]
    restrictions = [{
      geo_restriction = [{
        restriction_type = "none"
      }]
    }]
    viewer_certificate = [{
      cloudfront_default_certificate = true
    }]
  }
}