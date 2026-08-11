# Copyright IBM Corp. 2026

# MFA should be enabled for Cognito user pools

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.83.0, < 7.0.0"
    }
  }
}

input "cognito-user-pool-mfa-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cognito_user_pool" "mfa_enabled" {
    enforcement_level = input.cognito-user-pool-mfa-enabled-enforcement-level
    locals {
        # Extract sign-in policy configuration
        sign_in_policy = core::try(attrs.sign_in_policy, [])
        has_sign_in_policy = core::length(local.sign_in_policy) > 0
        
        # Get allowed first auth factors (empty list if not configured)
        allowed_first_auth_factors = local.has_sign_in_policy ? core::try(local.sign_in_policy[0].allowed_first_auth_factors, []) : []
        
        # Check if password-only sign-in is configured
        has_password_auth = core::contains(local.allowed_first_auth_factors, "PASSWORD")
        
        # Get MFA configuration (defaults to "OFF" if not specified)
        mfa_configuration = core::try(attrs.mfa_configuration, "OFF")
        
        # Check if MFA is enabled (ON or OPTIONAL)
        mfa_enabled = local.mfa_configuration == "ON" || local.mfa_configuration == "OPTIONAL"
        
        # Check if at least one MFA method is configured
        has_sms_config = core::try(attrs.sms_configuration, null) != null
        has_software_token_config = core::try(attrs.software_token_mfa_configuration, null) != null
        has_email_mfa_config = core::try(attrs.email_mfa_configuration, null) != null
        
        has_mfa_method = local.has_sms_config || local.has_software_token_config || local.has_email_mfa_config
        
        # Policy only applies to user pools with password-only sign-in
        requires_mfa_check = local.has_password_auth
    }
    
    # Only check user pools that have password-only sign-in configured
    filter = local.requires_mfa_check
    
    enforce {
        condition = local.mfa_enabled
        error_message = "Cognito user pool with password-only sign-in must have MFA enabled. Current mfa_configuration: '${local.mfa_configuration}'. Set mfa_configuration to 'ON' or 'OPTIONAL'"
    }
    
    enforce {
        condition = local.has_mfa_method
        error_message = "Cognito user pool must have at least one MFA method configured (sms_configuration, software_token_mfa_configuration, or email_mfa_configuration) when MFA is enabled"
    }
}
