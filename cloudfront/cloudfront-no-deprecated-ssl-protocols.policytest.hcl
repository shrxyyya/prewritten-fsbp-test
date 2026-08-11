# Copyright IBM Corp. 2026

policytest {
  targets = ["cloudfront-no-deprecated-ssl-protocols.policy.hcl"]
}

# Test 1: PASS - Custom origin with only TLSv1.2
resource "aws_cloudfront_distribution" "pass_custom_origin_tlsv12_only" {
  attrs = {
    enabled = true
    origin = [
      {
        domain_name = "example.com"
        origin_id = "custom-origin-1"
        custom_origin_config = [
          {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols = ["TLSv1.2"]
          }
        ]
      }
    ]
  }
}

# Test 2: FAIL - Custom origin includes SSLv3
resource "aws_cloudfront_distribution" "fail_custom_origin_with_sslv3" {
  expect_failure = true
  attrs = {
    enabled = true
    origin = [
      {
        domain_name = "insecure.example.com"
        origin_id = "custom-origin-1"
        custom_origin_config = [
          {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
          }
        ]
      }
    ]
  }
}

# Test 3: PASS - S3 origin only (no custom_origin_config)
resource "aws_cloudfront_distribution" "pass_s3_origin_only" {
  attrs = {
    enabled = true
    origin = [
      {
        domain_name = "mybucket.s3.amazonaws.com"
        origin_id = "s3-origin-1"
        s3_origin_config = [
          {
            origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
          }
        ]
      }
    ]
  }
}

# Test 4: FAIL - Multiple custom origins, one with SSLv3
resource "aws_cloudfront_distribution" "fail_multiple_origins_one_with_sslv3" {
  expect_failure = true
  attrs = {
    enabled = true
    origin = [
      {
        domain_name = "secure.example.com"
        origin_id = "custom-origin-1"
        custom_origin_config = [
          {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols = ["TLSv1.2"]
          }
        ]
      },
      {
        domain_name = "insecure.example.com"
        origin_id = "custom-origin-2"
        custom_origin_config = [
          {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols = ["SSLv3", "TLSv1.2"]
          }
        ]
      }
    ]
  }
}

# Test 5: PASS - Custom origin with TLSv1.1, TLSv1.2 (no deprecated protocols)
resource "aws_cloudfront_distribution" "pass_custom_origin_multiple_tls_no_sslv3" {
  attrs = {
    enabled = true
    origin = [
      {
        domain_name = "api.example.com"
        origin_id = "custom-origin-1"
        custom_origin_config = [
          {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols = ["TLSv1.1", "TLSv1.2"]
          }
        ]
      }
    ]
  }
}

# Test 6: PASS - Mixed origins (S3 + custom with TLSv1.2)
resource "aws_cloudfront_distribution" "pass_mixed_s3_and_custom_compliant" {
  attrs = {
    enabled = true
    origin = [
      {
        domain_name = "mybucket.s3.amazonaws.com"
        origin_id = "s3-origin-1"
        s3_origin_config = [
          {
            origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
          }
        ]
      },
      {
        domain_name = "api.example.com"
        origin_id = "custom-origin-1"
        custom_origin_config = [
          {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols = ["TLSv1.2"]
          }
        ]
      }
    ]
  }
}