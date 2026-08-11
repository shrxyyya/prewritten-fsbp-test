# Copyright IBM Corp. 2026

policytest {
  targets = [
    "acm-certificate-rsa-check.policy.hcl"
  ]
}
# Pass case: RSA_2048 meets minimum requirement
resource "aws_acm_certificate" "compliant_2048" {
  attrs = {
    key_algorithm = "RSA_2048"
    domain_name = "example.com"
  }
}

# Pass case: RSA_3072 exceeds minimum requirement
resource "aws_acm_certificate" "compliant_3072" {
  attrs = {
    key_algorithm = "RSA_3072"
    domain_name = "example.com"
  }
}

# Pass case: RSA_4096 exceeds minimum requirement
resource "aws_acm_certificate" "compliant_4096" {
  attrs = {
    key_algorithm = "RSA_4096"
    domain_name = "example.com"
  }
}

# Fail case: RSA_1024 does not meet minimum requirement
resource "aws_acm_certificate" "non_compliant_1024" {
  expect_failure = true
  attrs = {
    key_algorithm = "RSA_1024"
    domain_name = "example.com"
  }
}

# Pass case: EC_prime256v1 (Elliptic Curve) should be excluded
resource "aws_acm_certificate" "ec_cert_prime256" {
  attrs = {
    key_algorithm = "EC_prime256v1"
    domain_name = "example.com"
  }
}

# Pass case: EC_secp384r1 (Elliptic Curve) should be excluded
resource "aws_acm_certificate" "ec_cert_secp384" {
  attrs = {
    key_algorithm = "EC_secp384r1"
    domain_name = "example.com"
  }
}

# Pass case: EC_secp521r1 (Elliptic Curve) should be excluded
resource "aws_acm_certificate" "ec_cert_secp521" {
  attrs = {
    key_algorithm = "EC_secp521r1"
    domain_name = "example.com"
  }
}