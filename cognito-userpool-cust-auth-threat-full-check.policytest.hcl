# Copyright IBM Corp. 2026

policytest {
  targets = [
    "cognito-userpool-cust-auth-threat-full-check.policy.hcl"
  ]
}

# Test 1: Fully compliant user pool (should pass)
resource "aws_cognito_user_pool" "compliant_pool" {
  attrs = {
    name = "compliant-user-pool"
    user_pool_add_ons = [{
      advanced_security_mode = "ENFORCED"
      advanced_security_additional_flows = [{
        custom_auth_mode = "ENFORCED"
      }]
    }]
  }
}

# Test 2: User pool without user_pool_add_ons block (should fail)
resource "aws_cognito_user_pool" "no_add_ons" {
  expect_failure = true
  attrs = {
    name = "no-add-ons-pool"
  }
}

# Test 3: User pool with advanced_security_mode set to AUDIT (should fail)
resource "aws_cognito_user_pool" "audit_mode" {
  expect_failure = true
  attrs = {
    name = "audit-mode-pool"
    user_pool_add_ons = [{
      advanced_security_mode = "AUDIT"
      advanced_security_additional_flows = [{
        custom_auth_mode = "ENFORCED"
      }]
    }]
  }
}

# Test 4: User pool with advanced_security_mode set to OFF (should fail)
resource "aws_cognito_user_pool" "off_mode" {
  expect_failure = true
  attrs = {
    name = "off-mode-pool"
    user_pool_add_ons = [{
      advanced_security_mode = "OFF"
      advanced_security_additional_flows = [{
        custom_auth_mode = "ENFORCED"
      }]
    }]
  }
}

# Test 5: User pool without advanced_security_additional_flows block (should fail)
resource "aws_cognito_user_pool" "no_additional_flows" {
  expect_failure = true
  attrs = {
    name = "no-additional-flows-pool"
    user_pool_add_ons = [{
      advanced_security_mode = "ENFORCED"
    }]
  }
}

# Test 6: User pool with custom_auth_mode set to AUDIT (should fail)
resource "aws_cognito_user_pool" "custom_auth_audit" {
  expect_failure = true
  attrs = {
    name = "custom-auth-audit-pool"
    user_pool_add_ons = [{
      advanced_security_mode = "ENFORCED"
      advanced_security_additional_flows = [{
        custom_auth_mode = "AUDIT"
      }]
    }]
  }
}
