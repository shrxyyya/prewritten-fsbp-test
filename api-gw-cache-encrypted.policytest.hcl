# Copyright IBM Corp. 2026

policytest {
  targets = [
    "api-gw-cache-encrypted.policy.hcl"
  ]
}
# Test 1: PASS - Caching enabled with encryption
resource "aws_api_gateway_method_settings" "pass_caching_enabled_with_encryption" {
  attrs = {
    rest_api_id = "abc123"
    stage_name  = "prod"
    method_path = "*/GET"
    settings = [
      {
        caching_enabled      = true
        cache_data_encrypted = true
        cache_ttl_in_seconds = 300
      }
    ]
  }
}

# Test 2: FAIL - Caching enabled without encryption
resource "aws_api_gateway_method_settings" "fail_caching_enabled_without_encryption" {
  expect_failure = true
  attrs = {
    rest_api_id = "abc123"
    stage_name  = "prod"
    method_path = "*/POST"
    settings = [
      {
        caching_enabled      = true
        cache_data_encrypted = false
        cache_ttl_in_seconds = 300
      }
    ]
  }
}

# Test 3: FILTERED OUT - Caching disabled (should not be evaluated)
resource "aws_api_gateway_method_settings" "filtered_caching_disabled" {
  attrs = {
    rest_api_id = "abc123"
    stage_name  = "dev"
    method_path = "*/GET"
    settings = [
      {
        caching_enabled = false
      }
    ]
  }
}

# Test 4: FAIL - Caching enabled with explicit false for encryption
resource "aws_api_gateway_method_settings" "fail_explicit_false_encryption" {
  expect_failure = true
  attrs = {
    rest_api_id = "xyz789"
    stage_name  = "staging"
    method_path = "users/*/GET"
    settings = [
      {
        caching_enabled      = true
        cache_data_encrypted = false
        cache_ttl_in_seconds = 600
      }
    ]
  }
}

# Test 5: FAIL - Caching enabled but cache_data_encrypted not specified (defaults to false)
resource "aws_api_gateway_method_settings" "fail_encryption_not_specified" {
  expect_failure = true
  attrs = {
    rest_api_id = "def456"
    stage_name  = "test"
    method_path = "api/*/POST"
    settings = [
      {
        caching_enabled      = true
        cache_ttl_in_seconds = 120
      }
    ]
  }
}