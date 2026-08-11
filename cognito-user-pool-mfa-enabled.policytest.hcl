# Copyright IBM Corp. 2026

policytest {
  targets = [
    "cognito-user-pool-mfa-enabled.policy.hcl"
  ]
}

# Test 1: PASS - Password sign-in with MFA ON and SMS configuration
resource "aws_cognito_user_pool" "pass_mfa_on_sms" {
  attrs = {
    name = "test-pool-mfa-on-sms"
    sign_in_policy = [{
      allowed_first_auth_factors = ["PASSWORD"]
    }]
    mfa_configuration = "ON"
    sms_configuration = {
      external_id = "test-external-id"
      sns_caller_arn = "arn:aws:iam::123456789012:role/service-role/CognitoSNSRole"
    }
  }
}

# Test 2: PASS - Password sign-in with MFA OPTIONAL and software token configuration
resource "aws_cognito_user_pool" "pass_mfa_optional_software_token" {
  attrs = {
    name = "test-pool-mfa-optional-totp"
    sign_in_policy = [{
      allowed_first_auth_factors = ["PASSWORD"]
    }]
    mfa_configuration = "OPTIONAL"
    software_token_mfa_configuration = {
      enabled = true
    }
  }
}

# Test 3: PASS - Password sign-in with MFA ON and email MFA configuration
resource "aws_cognito_user_pool" "pass_mfa_on_email" {
  attrs = {
    name = "test-pool-mfa-on-email"
    sign_in_policy = [{
      allowed_first_auth_factors = ["PASSWORD"]
    }]
    mfa_configuration = "ON"
    email_mfa_configuration = {
      message = "Your verification code is {####}"
      subject = "Your verification code"
    }
  }
}

# Test 4: PASS - No password in allowed_first_auth_factors (policy not applicable)
resource "aws_cognito_user_pool" "pass_no_password_auth" {
  attrs = {
    name = "test-pool-no-password"
    sign_in_policy = [{
      allowed_first_auth_factors = ["EMAIL_OTP", "SMS_OTP"]
    }]
    mfa_configuration = "OFF"
  }
}

# Test 5: PASS - Multiple auth factors including password, MFA enabled
resource "aws_cognito_user_pool" "pass_multiple_auth_mfa_on" {
  attrs = {
    name = "test-pool-multiple-auth"
    sign_in_policy = [{
      allowed_first_auth_factors = ["PASSWORD", "EMAIL_OTP"]
    }]
    mfa_configuration = "ON"
    software_token_mfa_configuration = {
      enabled = true
    }
  }
}

# Test 6: FAIL - Password sign-in with MFA OFF
resource "aws_cognito_user_pool" "fail_mfa_off" {
  expect_failure = true
  attrs = {
    name = "test-pool-mfa-off"
    sign_in_policy = [{
      allowed_first_auth_factors = ["PASSWORD"]
    }]
    mfa_configuration = "OFF"
  }
}

# Test 7: FAIL - Password sign-in with MFA ON but no MFA method configured
resource "aws_cognito_user_pool" "fail_mfa_on_no_method" {
  expect_failure = true
  attrs = {
    name = "test-pool-no-mfa-method"
    sign_in_policy = [{
      allowed_first_auth_factors = ["PASSWORD"]
    }]
    mfa_configuration = "ON"
  }
}

# Test 8: FAIL - Password sign-in with MFA not specified (defaults to OFF)
resource "aws_cognito_user_pool" "fail_mfa_not_specified" {
  expect_failure = true
  attrs = {
    name = "test-pool-mfa-default"
    sign_in_policy = [{
      allowed_first_auth_factors = ["PASSWORD"]
    }]
  }
}

# Test 9: FAIL - Password sign-in with MFA OPTIONAL but no MFA method configured
resource "aws_cognito_user_pool" "fail_mfa_optional_no_method" {
  expect_failure = true
  attrs = {
    name = "test-pool-optional-no-method"
    sign_in_policy = [{
      allowed_first_auth_factors = ["PASSWORD"]
    }]
    mfa_configuration = "OPTIONAL"
  }
}
