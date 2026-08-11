terraform {
  required_version = ">= 1.15.0"

  cloud {

    organization = "nagateja-test-org"

    workspaces {
      name = "provider-test"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_cognito_user_pool" "example" {
  name = "example-user-pool"

  # cognito-user-pool-deletion-protection-enabled: must be ACTIVE
  deletion_protection = "ACTIVE"

  # cognito-user-pool-mfa-enabled: MFA ON with a method configured
  mfa_configuration = "ON"

  software_token_mfa_configuration {
    enabled = true
  }

  # cognito-user-pool-password-policy-check: strong password policy
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  # cognito-user-pool-mfa-enabled filter: password sign-in configured
  sign_in_policy {
    allowed_first_auth_factors = ["PASSWORD"]
  }

  # cognito-userpool-cust-auth-threat-full-check: threat protection enforced
  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"

    advanced_security_additional_flows {
      custom_auth_mode = "ENFORCED"
    }
  }
}

resource "aws_cognito_identity_pool" "example" {
  identity_pool_name = "example-identity-pool"

  # cognito-identity-pool-unauth-access-check: unauthenticated access must be false
  allow_unauthenticated_identities = false
}
