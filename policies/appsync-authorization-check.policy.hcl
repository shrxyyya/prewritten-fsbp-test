# Copyright IBM Corp. 2026

# AWS AppSync GraphQL APIs should not be authenticated with API keys

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "appsync-authorization-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_appsync_graphql_api" "no_api_key_auth" {
    enforcement_level = input.appsync-authorization-check-enforcement-level
    locals {
        # Allowed authentication types per AWS Security Hub control.
        # This list is fixed by the control and is not customizable.
        allowed_auth_types = ["AWS_LAMBDA", "AWS_IAM", "OPENID_CONNECT", "AMAZON_COGNITO_USER_POOLS"]
        
        # Get primary authentication type (required attribute)
        primary_auth_type = core::try(attrs.authentication_type, "")
        
        # Check if primary authentication uses API_KEY
        primary_uses_api_key = local.primary_auth_type == "API_KEY"
        
        # Get additional authentication providers (optional attribute)
        additional_providers = core::try(attrs.additional_authentication_provider, [])
        
        # Check if any additional provider uses API_KEY
        additional_api_key_providers = [
            for provider in local.additional_providers :
            provider if core::try(provider.authentication_type, "") == "API_KEY"
        ]
        
        has_additional_api_key = core::length(local.additional_api_key_providers) > 0
    }
    
    # Enforce: Primary authentication must not use API_KEY
    enforce {
        condition = !local.primary_uses_api_key
        error_message = "AppSync GraphQL API uses API_KEY for primary authentication. This control does not allow customization. Use one of the allowed authentication types: ${core::join(", ", local.allowed_auth_types)}"
    }
    
    # Enforce: Additional authentication providers must not use API_KEY
    enforce {
        condition = !local.has_additional_api_key
        error_message = "AppSync GraphQL API has ${core::length(local.additional_api_key_providers)} additional authentication provider(s) using API_KEY. This control does not allow customization. Use one of the allowed authentication types: ${core::join(", ", local.allowed_auth_types)}"
    }
}
