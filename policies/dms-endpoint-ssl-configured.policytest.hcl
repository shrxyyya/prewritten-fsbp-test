# Copyright IBM Corp. 2026

policytest {
  targets = [
    "dms-endpoint-ssl-configured.policy.hcl"
  ]
}

# Test 1: PASS - ssl_mode set to 'require'
resource "aws_dms_endpoint" "pass_ssl_mode_require" {
  attrs = {
    endpoint_id   = "test-endpoint-require"
    endpoint_type = "source"
    engine_name   = "mysql"
    ssl_mode      = "require"
    server_name   = "db.example.com"
    port          = 3306
    username      = "admin"
  }
}

# Test 2: PASS - ssl_mode set to 'verify-ca'
resource "aws_dms_endpoint" "pass_ssl_mode_verify_ca" {
  attrs = {
    endpoint_id     = "test-endpoint-verify-ca"
    endpoint_type   = "target"
    engine_name     = "postgres"
    ssl_mode        = "verify-ca"
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
    server_name     = "db.example.com"
    port            = 5432
    username        = "admin"
  }
}

# Test 3: PASS - ssl_mode set to 'verify-full'
resource "aws_dms_endpoint" "pass_ssl_mode_verify_full" {
  attrs = {
    endpoint_id     = "test-endpoint-verify-full"
    endpoint_type   = "source"
    engine_name     = "oracle"
    ssl_mode        = "verify-full"
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
    server_name     = "db.example.com"
    port            = 1521
    username        = "admin"
  }
}

# Test 4: FAIL - ssl_mode explicitly set to 'none'
resource "aws_dms_endpoint" "fail_ssl_mode_none" {
  expect_failure = true
  attrs = {
    endpoint_id   = "test-endpoint-none"
    endpoint_type = "source"
    engine_name   = "mysql"
    ssl_mode      = "none"
    server_name   = "db.example.com"
    port          = 3306
    username      = "admin"
  }
}

# Test 5: FAIL - ssl_mode not configured (defaults to 'none')
resource "aws_dms_endpoint" "fail_ssl_mode_not_configured" {
  expect_failure = true
  attrs = {
    endpoint_id   = "test-endpoint-default"
    endpoint_type = "target"
    engine_name   = "postgres"
    server_name   = "db.example.com"
    port          = 5432
    username      = "admin"
  }
}