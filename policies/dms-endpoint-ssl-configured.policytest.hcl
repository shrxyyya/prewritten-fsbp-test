# Copyright IBM Corp. 2026

policytest {
  targets = ["dms-endpoint-ssl-configured.policy.hcl"]
}

resource "aws_dms_endpoint" "pass_certificate_arn_literal" {
  attrs = {
    certificate_arn = "arn:aws:dms:us-east-1:123456789012:cert:ABCDEFG1234567890"
    endpoint_id     = "pass-certificate-literal"
    endpoint_type   = "source"
    engine_name     = "mysql"
  }
}

resource "aws_dms_endpoint" "pass_certificate_arn_reference" {
  attrs = {
    certificate_arn = "arn:aws:dms:us-east-1:123456789012:cert:REFERENCECERT1234"
    endpoint_id     = "pass-certificate-reference"
    endpoint_type   = "source"
    engine_name     = "mysql"
  }
}

resource "aws_dms_endpoint" "pass_source_endpoint_certificate" {
  attrs = {
    certificate_arn = "arn:aws:dms:us-east-1:123456789012:cert:SOURCECERT123456"
    endpoint_id     = "pass-source-certificate"
    endpoint_type   = "source"
    engine_name     = "postgres"
  }
}

resource "aws_dms_endpoint" "pass_target_endpoint_certificate" {
  attrs = {
    certificate_arn = "arn:aws:dms:us-east-1:123456789012:cert:TARGETCERT123456"
    endpoint_id     = "pass-target-certificate"
    endpoint_type   = "target"
    engine_name     = "redshift"
  }
}

resource "aws_dms_endpoint" "pass_certificate_with_ssl_none" {
  attrs = {
    certificate_arn = "arn:aws:dms:us-east-1:123456789012:cert:SSLMODEIGNORED12"
    endpoint_id     = "pass-ssl-mode-ignored"
    endpoint_type   = "source"
    engine_name     = "mysql"
    ssl_mode        = "none"
  }
}

resource "aws_dms_endpoint" "fail_certificate_arn_missing" {
  expect_failure = true
  attrs = {
    endpoint_id   = "fail-missing"
    endpoint_type = "target"
    engine_name   = "postgres"
  }
}

resource "aws_dms_endpoint" "fail_certificate_arn_null" {
  expect_failure = true
  attrs = {
    certificate_arn = null
    endpoint_id     = "fail-null"
    endpoint_type   = "source"
    engine_name     = "mysql"
  }
}

resource "aws_dms_endpoint" "fail_certificate_arn_empty_string" {
  expect_failure = true
  attrs = {
    certificate_arn = ""
    endpoint_id     = "fail-empty"
    endpoint_type   = "source"
    engine_name     = "mysql"
  }
}

resource "aws_dms_endpoint" "fail_ssl_mode_without_certificate" {
  expect_failure = true
  attrs = {
    endpoint_id   = "fail-ssl-mode-only"
    endpoint_type = "source"
    engine_name   = "mysql"
    ssl_mode      = "require"
  }
}

resource "aws_dms_endpoint" "fail_invalid_ssl_mode_without_certificate" {
  expect_failure = true
  attrs = {
    endpoint_id   = "fail-invalid-ssl-mode-only"
    endpoint_type = "source"
    engine_name   = "sqlserver"
    ssl_mode      = "ssl-enabled"
  }
}
