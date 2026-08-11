# Copyright IBM Corp. 2026

# Cognito identity pools should not allow unauthenticated identities

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cognito-identity-pool-unauth-access-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cognito_identity_pool" "no_unauthenticated_access" {
    enforcement_level = input.cognito-identity-pool-unauth-access-check-enforcement-level
    # Safe access to the allow_unauthenticated_identities attribute
    # Default to true (fail-safe) if attribute doesn't exist
    locals {
        allows_unauth = core::try(attrs.allow_unauthenticated_identities, true)
    }

    # Enforce that unauthenticated identities are not allowed
    enforce {
        condition = local.allows_unauth == false
        error_message = "Cognito identity pool must not allow unauthenticated identities. Set 'allow_unauthenticated_identities' to false"
    }
}
