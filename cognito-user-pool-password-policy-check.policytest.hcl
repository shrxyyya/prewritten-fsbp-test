# Copyright IBM Corp. 2026

policytest {
  targets = [
    "cognito-user-pool-password-policy-check.policy.hcl"
  ]
}

# Pass case: Strong password policy with all requirements met
resource "aws_cognito_user_pool" "pass_strong_password_policy" {
  attrs = {
    name = "compliant-pool"
    password_policy = [
      {
        minimum_length                  = 8
        require_lowercase               = true
        require_uppercase               = true
        require_numbers                 = true
        require_symbols                 = true
        temporary_password_validity_days = 7
      }
    ]
  }
}

# Fail case: Minimum length less than 8
resource "aws_cognito_user_pool" "fail_minimum_length_too_short" {
  expect_failure = true
  attrs = {
    name = "weak-length-pool"
    password_policy = [
      {
        minimum_length                  = 6
        require_lowercase               = true
        require_uppercase               = true
        require_numbers                 = true
        require_symbols                 = true
        temporary_password_validity_days = 7
      }
    ]
  }
}

# Fail case: Missing lowercase requirement
resource "aws_cognito_user_pool" "fail_no_lowercase_requirement" {
  expect_failure = true
  attrs = {
    name = "no-lowercase-pool"
    password_policy = [
      {
        minimum_length                  = 8
        require_lowercase               = false
        require_uppercase               = true
        require_numbers                 = true
        require_symbols                 = true
        temporary_password_validity_days = 7
      }
    ]
  }
}

# Fail case: Missing uppercase requirement
resource "aws_cognito_user_pool" "fail_no_uppercase_requirement" {
  expect_failure = true
  attrs = {
    name = "no-uppercase-pool"
    password_policy = [
      {
        minimum_length                  = 8
        require_lowercase               = true
        require_uppercase               = false
        require_numbers                 = true
        require_symbols                 = true
        temporary_password_validity_days = 7
      }
    ]
  }
}

# Fail case: Missing numbers requirement
resource "aws_cognito_user_pool" "fail_no_numbers_requirement" {
  expect_failure = true
  attrs = {
    name = "no-numbers-pool"
    password_policy = [
      {
        minimum_length                  = 8
        require_lowercase               = true
        require_uppercase               = true
        require_numbers                 = false
        require_symbols                 = true
        temporary_password_validity_days = 7
      }
    ]
  }
}

# Fail case: Missing symbols requirement
resource "aws_cognito_user_pool" "fail_no_symbols_requirement" {
  expect_failure = true
  attrs = {
    name = "no-symbols-pool"
    password_policy = [
      {
        minimum_length                  = 8
        require_lowercase               = true
        require_uppercase               = true
        require_numbers                 = true
        require_symbols                 = false
        temporary_password_validity_days = 7
      }
    ]
  }
}

# Fail case: Multiple violations (no lowercase and no symbols)
resource "aws_cognito_user_pool" "fail_multiple_violations" {
  expect_failure = true
  attrs = {
    name = "multiple-violations-pool"
    password_policy = [
      {
        minimum_length                  = 8
        require_lowercase               = false
        require_uppercase               = true
        require_numbers                 = true
        require_symbols                 = false
        temporary_password_validity_days = 7
      }
    ]
  }
}

# Pass case: Boundary case with minimum length exactly 8
resource "aws_cognito_user_pool" "pass_minimum_length_exactly_8" {
  attrs = {
    name = "boundary-case-pool"
    password_policy = [
      {
        minimum_length                  = 8
        require_lowercase               = true
        require_uppercase               = true
        require_numbers                 = true
        require_symbols                 = true
        temporary_password_validity_days = 7
      }
    ]
  }
}

# Pass case: Minimum length greater than 8
resource "aws_cognito_user_pool" "pass_minimum_length_exceeds_requirement" {
  attrs = {
    name = "exceeds-minimum-pool"
    password_policy = [
      {
        minimum_length                  = 12
        require_lowercase               = true
        require_uppercase               = true
        require_numbers                 = true
        require_symbols                 = true
        temporary_password_validity_days = 7
      }
    ]
  }
}

# Fail case: Temporary password validity exceeds default threshold
resource "aws_cognito_user_pool" "fail_temporary_password_validity_too_high" {
  expect_failure = true
  attrs = {
    name = "temporary-password-too-high-pool"
    password_policy = [
      {
        minimum_length                  = 8
        require_lowercase               = true
        require_uppercase               = true
        require_numbers                 = true
        require_symbols                 = true
        temporary_password_validity_days = 10
      }
    ]
  }
}

# Fail case: Missing password policy block entirely
resource "aws_cognito_user_pool" "fail_missing_password_policy" {
  expect_failure = true
  attrs = {
    name = "missing-password-policy-pool"
  }
}