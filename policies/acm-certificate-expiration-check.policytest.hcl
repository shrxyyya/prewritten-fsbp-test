# Copyright IBM Corp. 2026

policytest {
  targets = [
    "acm-certificate-expiration-check.policy.hcl"
  ]
}

# Test 1: Pass - Certificate eligible for automatic renewal
resource "aws_acm_certificate" "pass_eligible_for_renewal" {
  attrs = {
    not_after = "2026-12-31T23:59:59Z"
    renewal_eligibility = "ELIGIBLE"
    type = "AMAZON_ISSUED"
    status = "ISSUED"
    domain_name = "example.com"
    arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  }
}

# Test 2: Pass - Imported certificate (manual renewal required)
resource "aws_acm_certificate" "pass_imported_certificate" {
  attrs = {
    not_after = "2026-12-31T23:59:59Z"
    renewal_eligibility = "INELIGIBLE"
    type = "IMPORTED"
    status = "ISSUED"
    domain_name = "imported.example.com"
    arn = "arn:aws:acm:us-east-1:123456789012:certificate/imported-cert"
  }
}

# Test 3: Fail - Certificate needs attention (not eligible, not imported)
resource "aws_acm_certificate" "fail_needs_attention" {
  expect_failure = true
  attrs = {
    not_after = "2026-12-31T23:59:59Z"
    renewal_eligibility = "INELIGIBLE"
    type = "AMAZON_ISSUED"
    status = "ISSUED"
    domain_name = "problem.example.com"
    arn = "arn:aws:acm:us-east-1:123456789012:certificate/problem-cert"
  }
}

# Test 4: Fail - Missing expiration date
resource "aws_acm_certificate" "fail_missing_expiration" {
  expect_failure = true
  attrs = {
    not_after = null
    renewal_eligibility = "ELIGIBLE"
    type = "AMAZON_ISSUED"
    status = "ISSUED"
    domain_name = "noexpiry.example.com"
    arn = "arn:aws:acm:us-east-1:123456789012:certificate/no-expiry"
  }
}

# Test 5: Pass - Pending validation (not yet issued)
resource "aws_acm_certificate" "pass_pending_validation" {
  attrs = {
    not_after = "2026-12-31T23:59:59Z"
    renewal_eligibility = "INELIGIBLE"
    type = "AMAZON_ISSUED"
    status = "PENDING_VALIDATION"
    domain_name = "pending.example.com"
    arn = "arn:aws:acm:us-east-1:123456789012:certificate/pending-cert"
  }
}

# Test 6: Pass - Private CA certificate eligible for renewal
resource "aws_acm_certificate" "pass_private_ca_eligible" {
  attrs = {
    not_after = "2026-12-31T23:59:59Z"
    renewal_eligibility = "ELIGIBLE"
    type = "PRIVATE"
    status = "ISSUED"
    domain_name = "private.example.com"
    arn = "arn:aws:acm:us-east-1:123456789012:certificate/private-cert"
    certificate_authority_arn = "arn:aws:acm-pca:us-east-1:123456789012:certificate-authority/12345678-1234-1234-1234-123456789012"
  }
}