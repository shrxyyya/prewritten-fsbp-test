# Copyright IBM Corp. 2026

# Cognito user pools should have threat protection activated with full function enforcement mode for custom authentication

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cognito-userpool-cust-auth-threat-full-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cognito_user_pool" "threat_protection_enforced" {
    enforcement_level = input.cognito-userpool-cust-auth-threat-full-check-enforcement-level
    locals {
        # Check if user_pool_add_ons block exists
        add_ons = core::try(attrs.user_pool_add_ons, [])
        has_add_ons = core::length(local.add_ons) > 0
        
        # Get advanced_security_mode (blocks are lists, use [0] index)
        security_mode = local.has_add_ons ? core::try(local.add_ons[0].advanced_security_mode, "") : ""
        
        # Check if advanced_security_additional_flows exists
        additional_flows = local.has_add_ons ? core::try(local.add_ons[0].advanced_security_additional_flows, []) : []
        has_additional_flows = core::length(local.additional_flows) > 0
        
        # Get custom_auth_mode
        custom_auth_mode = local.has_additional_flows ? core::try(local.additional_flows[0].custom_auth_mode, "") : ""
        
        # Validation checks
        is_security_enforced = local.security_mode == "ENFORCED"
        is_custom_auth_enforced = local.custom_auth_mode == "ENFORCED"
    }

    enforce {
        condition = local.has_add_ons
        error_message = "Cognito user pool must have user_pool_add_ons block configured for threat protection"
    }

    enforce {
        condition = local.is_security_enforced
        error_message = "Cognito user pool must have advanced_security_mode set to 'ENFORCED' (current: '${local.security_mode}')"
    }

    enforce {
        condition = local.has_additional_flows
        error_message = "Cognito user pool must have advanced_security_additional_flows block configured"
    }

    enforce {
        condition = local.is_custom_auth_enforced
        error_message = "Cognito user pool must have custom_auth_mode set to 'ENFORCED' for full function enforcement (current: '${local.custom_auth_mode}')"
    }
}
