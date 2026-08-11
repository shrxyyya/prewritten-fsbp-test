# Copyright IBM Corp. 2026

# API Gateway V2 integrations should use HTTPS for private connections

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "apigatewayv2-integration-private-https-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_apigatewayv2_integration" "private_https_enabled" {
    enforcement_level = input.apigatewayv2-integration-private-https-enabled-enforcement-level
    # Only evaluate integrations that use VPC Links (private connections)
    # INTERNET connections don't need this check as they use public HTTPS
    filter = core::try(attrs.connection_type, "") == "VPC_LINK"

    locals {
        # Safe access to connection type
        connection_type = core::try(attrs.connection_type, "")
        
        # Check if tls_config block exists and is configured
        # tls_config is a block (list of maps), so we check if it exists and has content
        has_tls_config = core::try(core::length(attrs.tls_config), 0) > 0
        
        # Get integration URI for better error messages
        integration_uri = core::try(attrs.integration_uri, "unknown")
    }

    enforce {
        condition = local.has_tls_config
        error_message = "API Gateway V2 integration uses VPC Link (private connection) but does not have TLS configuration enabled. Private integrations must use HTTPS to encrypt data in transit. Configure 'tls_config' block with 'server_name_to_verify' to enable TLS/HTTPS encryption for the private connection to '${local.integration_uri}'"
    }
}
