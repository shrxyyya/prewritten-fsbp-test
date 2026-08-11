# Copyright IBM Corp. 2026

# API Gateway REST API cache data should be encrypted at rest

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "api-gw-cache-encrypted-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_api_gateway_method_settings" "cache_encryption_required" {
    enforcement_level = input.api-gw-cache-encrypted-enforcement-level
    # Only evaluate method settings that have caching enabled
    filter = core::try(attrs.settings[0].caching_enabled, false) == true

    locals {
        # Safely extract cache encryption setting
        cache_data_encrypted = core::try(attrs.settings[0].cache_data_encrypted, false)
        
        # Get method path for error message
        method_path = core::try(attrs.method_path, "unknown")
        
        # Get stage name for error message
        stage_name = core::try(attrs.stage_name, "unknown")
    }

    enforce {
        condition = local.cache_data_encrypted == true
        error_message = "API Gateway method '${local.method_path}' in stage '${local.stage_name}' has caching enabled but cache data is not encrypted. Enable cache encryption by setting cache_data_encrypted = true in the method settings"
    }
}
