# Copyright IBM Corp. 2026

policytest {
  targets = [
    "cognito-identity-pool-unauth-access-check.policy.hcl"
  ]
}

# Test 1: PASS - allow_unauthenticated_identities is false (compliant)
resource "aws_cognito_identity_pool" "pass_unauthenticated_disabled" {
  attrs = {
    identity_pool_name               = "compliant_pool"
    allow_unauthenticated_identities = false
    allow_classic_flow               = false
  }
}

# Test 2: FAIL - allow_unauthenticated_identities is true (non-compliant)
resource "aws_cognito_identity_pool" "fail_unauthenticated_enabled" {
  expect_failure = true
  attrs = {
    identity_pool_name               = "non_compliant_pool"
    allow_unauthenticated_identities = true
    allow_classic_flow               = false
  }
}

# Test 3: FAIL - allow_unauthenticated_identities attribute is missing (fail-safe)
resource "aws_cognito_identity_pool" "fail_attribute_missing" {
  expect_failure = true
  attrs = {
    identity_pool_name = "pool_without_auth_setting"
    allow_classic_flow = false
  }
}