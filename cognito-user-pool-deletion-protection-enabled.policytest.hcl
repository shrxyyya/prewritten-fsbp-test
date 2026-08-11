# Copyright IBM Corp. 2026

policytest {
  targets = [
    "cognito-user-pool-deletion-protection-enabled.policy.hcl"
  ]
}

# Test case 1: User pool with deletion_protection set to ACTIVE (should pass)
resource "aws_cognito_user_pool" "compliant" {
  attrs = {
    name = "test-user-pool-compliant"
    deletion_protection = "ACTIVE"
  }
}

# Test case 2: User pool with deletion_protection set to INACTIVE (should fail)
resource "aws_cognito_user_pool" "non_compliant_inactive" {
  expect_failure = true
  attrs = {
    name = "test-user-pool-inactive"
    deletion_protection = "INACTIVE"
  }
}

# Test case 3: User pool without deletion_protection attribute (should fail, defaults to INACTIVE)
resource "aws_cognito_user_pool" "non_compliant_missing" {
  expect_failure = true
  attrs = {
    name = "test-user-pool-missing"
  }
}
