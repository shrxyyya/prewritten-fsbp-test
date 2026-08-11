# Copyright IBM Corp. 2026

# Cognito user pools should have deletion protection enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.38.0, < 7.0.0"
    }
  }
}

input "cognito-user-pool-deletion-protection-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cognito_user_pool" "deletion_protection_enabled" {
    enforcement_level = input.cognito-user-pool-deletion-protection-enabled-enforcement-level
    locals {
        # Safely access deletion_protection attribute with default value "INACTIVE"
        deletion_protection = core::try(attrs.deletion_protection, "INACTIVE")
    }

    enforce {
        condition = local.deletion_protection == "ACTIVE"
        error_message = "Cognito user pool must have deletion protection enabled. Current value: '${local.deletion_protection}'. Set deletion_protection to 'ACTIVE'"
    }
}
