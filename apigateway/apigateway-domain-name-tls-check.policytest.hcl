# Copyright IBM Corp. 2026

policytest {
  targets = [
    "apigateway-domain-name-tls-check.policy.hcl"
  ]
}

# Pass case: SecurityPolicy_TLS13_1_3_2025_09 (latest recommended)
resource "aws_api_gateway_domain_name" "pass_security_policy_tls13_1_3_2025_09" {
  attrs = {
    domain_name = "api5.example.com"
    security_policy = "SecurityPolicy_TLS13_1_3_2025_09"
    regional_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/example"
  }
}

# Fail case: security_policy not set
resource "aws_api_gateway_domain_name" "fail_no_security_policy" {
  expect_failure = true
  attrs = {
    domain_name = "api6.example.com"
    regional_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/example"
  }
}

# Fail case: TLS-1-0 (deprecated)
resource "aws_api_gateway_domain_name" "fail_tls_1_0_deprecated" {
  expect_failure = true
  attrs = {
    domain_name = "api7.example.com"
    security_policy = "TLS-1-0"
    regional_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/example"
  }
}

# Fail case: TLS_1_0 (deprecated alternative format)
resource "aws_api_gateway_domain_name" "fail_tls_1_0_alt_format" {
  expect_failure = true
  attrs = {
    domain_name = "api8.example.com"
    security_policy = "TLS_1_0"
    regional_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/example"
  }
}

# Fail case: Unknown security policy
resource "aws_api_gateway_domain_name" "fail_unknown_policy" {
  expect_failure = true
  attrs = {
    domain_name = "api9.example.com"
    security_policy = "UNKNOWN_POLICY"
    regional_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/example"
  }
}