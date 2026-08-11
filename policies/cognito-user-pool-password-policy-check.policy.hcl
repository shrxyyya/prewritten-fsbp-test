# Copyright IBM Corp. 2026

# Cognito user pools should have a strong password policy

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cognito-user-pool-password-policy-check-enforcement-level" {
  type = string
  default = "advisory"
}

input "minLength" {
    type = number
    default = 8
}

input "requireLowercase" {
    type = bool
    default = true
}

input "requireUppercase" {
    type = bool
    default = true
}

input "requireNumbers" {
    type = bool
    default = true
}

input "requireSymbols" {
    type = bool
    default = true
}

input "temporaryPasswordValidity" {
    type = number
    default = 7
}

resource_policy "aws_cognito_user_pool" "cognito3_password_policy" {
    enforcement_level = input.cognito-user-pool-password-policy-check-enforcement-level
    locals {
        user_pool_name = core::try(attrs.name, "unknown")
        password_policy = core::try(attrs.password_policy[0], {})

        minimum_length = core::try(local.password_policy.minimum_length, 0)
        require_lowercase = core::try(local.password_policy.require_lowercase, false)
        require_numbers = core::try(local.password_policy.require_numbers, false)
        require_symbols = core::try(local.password_policy.require_symbols, false)
        require_uppercase = core::try(local.password_policy.require_uppercase, false)
        temporary_password_validity_days = core::try(local.password_policy.temporary_password_validity_days, 0)

        valid_min_length_input = input.minLength >= 8 && input.minLength <= 128
        valid_temporary_password_validity_input = input.temporaryPasswordValidity >= 1 && input.temporaryPasswordValidity <= 365

        has_minimum_length = local.minimum_length >= input.minLength
        has_required_lowercase = local.require_lowercase == input.requireLowercase
        has_required_uppercase = local.require_uppercase == input.requireUppercase
        has_required_numbers = local.require_numbers == input.requireNumbers
        has_required_symbols = local.require_symbols == input.requireSymbols
        has_valid_temporary_password_validity = local.temporary_password_validity_days > 0 && local.temporary_password_validity_days <= input.temporaryPasswordValidity
    }

    enforce {
        condition = local.valid_min_length_input
        error_message = "input.minLength must be between 8 and 128. Current value: ${input.minLength}."
    }

    enforce {
        condition = local.valid_temporary_password_validity_input
        error_message = "input.temporaryPasswordValidity must be between 1 and 365. Current value: ${input.temporaryPasswordValidity}."
    }

    enforce {
        condition = local.has_minimum_length
        error_message = "Cognito user pool '${local.user_pool_name}' password policy must require a minimum length of at least ${input.minLength} characters. Current minimum length: ${local.minimum_length}"
    }

    enforce {
        condition = local.has_required_lowercase
        error_message = "Cognito user pool '${local.user_pool_name}' password policy must set require_lowercase to '${input.requireLowercase}'. Current value: '${local.require_lowercase}'"
    }

    enforce {
        condition = local.has_required_numbers
        error_message = "Cognito user pool '${local.user_pool_name}' password policy must set require_numbers to '${input.requireNumbers}'. Current value: '${local.require_numbers}'"
    }

    enforce {
        condition = local.has_required_symbols
        error_message = "Cognito user pool '${local.user_pool_name}' password policy must set require_symbols to '${input.requireSymbols}'. Current value: '${local.require_symbols}'"
    }

    enforce {
        condition = local.has_required_uppercase
        error_message = "Cognito user pool '${local.user_pool_name}' password policy must set require_uppercase to '${input.requireUppercase}'. Current value: '${local.require_uppercase}'"
    }

    enforce {
        condition = local.has_valid_temporary_password_validity
        error_message = "Cognito user pool '${local.user_pool_name}' password policy must set temporary_password_validity_days to a value between 1 and ${input.temporaryPasswordValidity}. Current value: ${local.temporary_password_validity_days}"
    }
}
