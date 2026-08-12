# Copyright IBM Corp. 2026

# DMS endpoints should use SSL

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "dms-endpoint-ssl-configured-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_dms_endpoint" "dms_endpoint_ssl_configured" {
    enforcement_level = input.dms-endpoint-ssl-configured-enforcement-level
    locals {
        # Safe access to ssl_mode attribute with default fallback
        ssl_mode = core::try(attrs.ssl_mode, "none")
        
        # List of allowed SSL modes that satisfy the security requirement
        allowed_ssl_modes = ["require", "verify-ca", "verify-full"]
        
        # Check if the configured ssl_mode is in the allowed list
        is_ssl_enabled = core::contains(local.allowed_ssl_modes, local.ssl_mode)
    }

    enforce {
        condition = local.is_ssl_enabled
        error_message = "DMS endpoint must use SSL connection. Current ssl_mode: '${local.ssl_mode}'. Allowed values: 'require', 'verify-ca', or 'verify-full'"
    }
}
