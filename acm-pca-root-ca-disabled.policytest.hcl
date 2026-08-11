# Copyright IBM Corp. 2026

policytest {
  targets = [
    "acm-pca-root-ca-disabled.policy.hcl"
  ]
}

// Test 1: PASS - Root CA with enabled = false (compliant)
resource "aws_acmpca_certificate_authority" "pass_root_ca_disabled" {
  attrs = {
    type = "ROOT"
    enabled = false
    certificate_authority_configuration = {
      key_algorithm = "RSA_4096"
      signing_algorithm = "SHA512WITHRSA"
      subject = {
        common_name = "example.com"
      }
    }
  }
}

// Test 2: FAIL - Root CA with enabled = true (non-compliant)
resource "aws_acmpca_certificate_authority" "fail_root_ca_enabled_explicit" {
  expect_failure = true
  attrs = {
    type = "ROOT"
    enabled = true
    certificate_authority_configuration = {
      key_algorithm = "RSA_4096"
      signing_algorithm = "SHA512WITHRSA"
      subject = {
        common_name = "example.com"
      }
    }
  }
}

// Test 3: FAIL - Root CA without enabled attribute (defaults to true, non-compliant)
resource "aws_acmpca_certificate_authority" "fail_root_ca_enabled_default" {
  expect_failure = true
  attrs = {
    type = "ROOT"
    certificate_authority_configuration = {
      key_algorithm = "RSA_4096"
      signing_algorithm = "SHA512WITHRSA"
      subject = {
        common_name = "example.com"
      }
    }
  }
}

// Test 4: PASS - Subordinate CA with enabled = true (filtered out, not evaluated)
resource "aws_acmpca_certificate_authority" "pass_subordinate_ca_not_evaluated" {
  attrs = {
    type = "SUBORDINATE"
    enabled = true
    certificate_authority_configuration = {
      key_algorithm = "RSA_2048"
      signing_algorithm = "SHA256WITHRSA"
      subject = {
        common_name = "sub.example.com"
      }
    }
  }
}

// Test 5: PASS - Subordinate CA without type attribute (defaults to SUBORDINATE, filtered out)
resource "aws_acmpca_certificate_authority" "pass_subordinate_ca_default_type" {
  attrs = {
    enabled = true
    certificate_authority_configuration = {
      key_algorithm = "RSA_2048"
      signing_algorithm = "SHA256WITHRSA"
      subject = {
        common_name = "sub.example.com"
      }
    }
  }
}