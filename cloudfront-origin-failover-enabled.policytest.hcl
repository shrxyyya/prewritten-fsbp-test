# Copyright IBM Corp. 2026

policytest {
  targets = ["cloudfront-origin-failover-enabled.policy.hcl"]
}

# Test 1: PASS - Properly configured origin group with two members and cache behavior referencing it
resource "aws_cloudfront_distribution" "pass_complete_configuration" {
  attrs = {
    enabled = true
    origin_group = [
      {
        origin_id = "groupS3"
        failover_criteria = [
          {
            status_codes = [403, 404, 500, 502]
          }
        ]
        member = [
          {
            origin_id = "primaryS3"
          },
          {
            origin_id = "failoverS3"
          }
        ]
      }
    ]
    origin = [
      {
        domain_name = "primary-bucket.s3.amazonaws.com"
        origin_id = "primaryS3"
      },
      {
        domain_name = "failover-bucket.s3.amazonaws.com"
        origin_id = "failoverS3"
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id = "groupS3"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
      }
    ]
  }
}

# Test 2: FAIL - No origin_group configured
resource "aws_cloudfront_distribution" "fail_no_origin_group" {
  expect_failure = true
  attrs = {
    enabled = true
    origin = [
      {
        domain_name = "bucket.s3.amazonaws.com"
        origin_id = "S3-bucket"
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id = "S3-bucket"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
      }
    ]
  }
}

# Test 3: FAIL - Origin group with only one member
resource "aws_cloudfront_distribution" "fail_single_member" {
  expect_failure = true
  attrs = {
    enabled = true
    origin_group = [
      {
        origin_id = "groupS3"
        failover_criteria = [
          {
            status_codes = [500, 502]
          }
        ]
        member = [
          {
            origin_id = "primaryS3"
          }
        ]
      }
    ]
    origin = [
      {
        domain_name = "bucket.s3.amazonaws.com"
        origin_id = "primaryS3"
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id = "groupS3"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
      }
    ]
  }
}

# Test 4: FAIL - Origin group without failover_criteria
resource "aws_cloudfront_distribution" "fail_no_failover_criteria" {
  expect_failure = true
  attrs = {
    enabled = true
    origin_group = [
      {
        origin_id = "groupS3"
        member = [
          {
            origin_id = "primaryS3"
          },
          {
            origin_id = "failoverS3"
          }
        ]
      }
    ]
    origin = [
      {
        domain_name = "primary-bucket.s3.amazonaws.com"
        origin_id = "primaryS3"
      },
      {
        domain_name = "failover-bucket.s3.amazonaws.com"
        origin_id = "failoverS3"
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id = "groupS3"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
      }
    ]
  }
}

# Test 5: FAIL - Failover criteria without status_codes
resource "aws_cloudfront_distribution" "fail_no_status_codes" {
  expect_failure = true
  attrs = {
    enabled = true
    origin_group = [
      {
        origin_id = "groupS3"
        failover_criteria = [
          {
            status_codes = []
          }
        ]
        member = [
          {
            origin_id = "primaryS3"
          },
          {
            origin_id = "failoverS3"
          }
        ]
      }
    ]
    origin = [
      {
        domain_name = "primary-bucket.s3.amazonaws.com"
        origin_id = "primaryS3"
      },
      {
        domain_name = "failover-bucket.s3.amazonaws.com"
        origin_id = "failoverS3"
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id = "groupS3"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
      }
    ]
  }
}

# Test 6: FAIL - Cache behavior references individual origin instead of origin_group
resource "aws_cloudfront_distribution" "fail_cache_behavior_wrong_target" {
  expect_failure = true
  attrs = {
    enabled = true
    origin_group = [
      {
        origin_id = "groupS3"
        failover_criteria = [
          {
            status_codes = [403, 404, 500, 502]
          }
        ]
        member = [
          {
            origin_id = "primaryS3"
          },
          {
            origin_id = "failoverS3"
          }
        ]
      }
    ]
    origin = [
      {
        domain_name = "primary-bucket.s3.amazonaws.com"
        origin_id = "primaryS3"
      },
      {
        domain_name = "failover-bucket.s3.amazonaws.com"
        origin_id = "failoverS3"
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id = "primaryS3"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
      }
    ]
  }
}

# Test 7: PASS - Multiple origin groups with ordered cache behavior
resource "aws_cloudfront_distribution" "pass_multiple_groups_ordered_behavior" {
  attrs = {
    enabled = true
    origin_group = [
      {
        origin_id = "groupS3"
        failover_criteria = [
          {
            status_codes = [403, 404, 500, 502]
          }
        ]
        member = [
          {
            origin_id = "primaryS3"
          },
          {
            origin_id = "failoverS3"
          }
        ]
      },
      {
        origin_id = "groupCustom"
        failover_criteria = [
          {
            status_codes = [500, 502, 503, 504]
          }
        ]
        member = [
          {
            origin_id = "primaryCustom"
          },
          {
            origin_id = "failoverCustom"
          }
        ]
      }
    ]
    origin = [
      {
        domain_name = "primary-bucket.s3.amazonaws.com"
        origin_id = "primaryS3"
      },
      {
        domain_name = "failover-bucket.s3.amazonaws.com"
        origin_id = "failoverS3"
      },
      {
        domain_name = "primary.example.com"
        origin_id = "primaryCustom"
      },
      {
        domain_name = "failover.example.com"
        origin_id = "failoverCustom"
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id = "groupS3"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
      }
    ]
    ordered_cache_behavior = [
      {
        path_pattern = "/api/*"
        target_origin_id = "groupCustom"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD", "POST", "PUT", "DELETE"]
        cached_methods = ["GET", "HEAD"]
      }
    ]
  }
}

# Test 8: PASS - Origin group with three members (exceeds minimum requirement)
resource "aws_cloudfront_distribution" "pass_three_members" {
  attrs = {
    enabled = true
    origin_group = [
      {
        origin_id = "groupS3"
        failover_criteria = [
          {
            status_codes = [403, 404, 500, 502]
          }
        ]
        member = [
          {
            origin_id = "primaryS3"
          },
          {
            origin_id = "failoverS3_1"
          },
          {
            origin_id = "failoverS3_2"
          }
        ]
      }
    ]
    origin = [
      {
        domain_name = "primary-bucket.s3.amazonaws.com"
        origin_id = "primaryS3"
      },
      {
        domain_name = "failover-bucket-1.s3.amazonaws.com"
        origin_id = "failoverS3_1"
      },
      {
        domain_name = "failover-bucket-2.s3.amazonaws.com"
        origin_id = "failoverS3_2"
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id = "groupS3"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
      }
    ]
  }
}

# Test 9: FAIL - Origin group with empty origin_id
resource "aws_cloudfront_distribution" "fail_empty_origin_id" {
  expect_failure = true
  attrs = {
    enabled = true
    origin_group = [
      {
        origin_id = ""
        failover_criteria = [
          {
            status_codes = [403, 404, 500, 502]
          }
        ]
        member = [
          {
            origin_id = "primaryS3"
          },
          {
            origin_id = "failoverS3"
          }
        ]
      }
    ]
    origin = [
      {
        domain_name = "primary-bucket.s3.amazonaws.com"
        origin_id = "primaryS3"
      },
      {
        domain_name = "failover-bucket.s3.amazonaws.com"
        origin_id = "failoverS3"
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id = ""
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
      }
    ]
  }
}

# Test 10: Filtered out - Distribution with null enabled attribute
resource "aws_cloudfront_distribution" "filtered_null_enabled" {
  attrs = {
    enabled = null
    origin_group = [
      {
        origin_id = "groupS3"
        failover_criteria = [
          {
            status_codes = [403, 404, 500, 502]
          }
        ]
        member = [
          {
            origin_id = "primaryS3"
          },
          {
            origin_id = "failoverS3"
          }
        ]
      }
    ]
    origin = [
      {
        domain_name = "primary-bucket.s3.amazonaws.com"
        origin_id = "primaryS3"
      },
      {
        domain_name = "failover-bucket.s3.amazonaws.com"
        origin_id = "failoverS3"
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id = "groupS3"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
      }
    ]
  }
}