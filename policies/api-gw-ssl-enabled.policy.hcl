# Copyright IBM Corp. 2026

# API Gateway REST API stages should be configured to use SSL certificates for backend authentication
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "api-gw-ssl-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_api_gateway_stage" "ssl_backend_auth_required" {
    enforcement_level = input.api-gw-ssl-enabled-enforcement-level
    locals {
        # Safely extract client_certificate_id attribute
        client_cert_id = core::try(attrs.client_certificate_id, null)
        
        # Check if certificate is configured
        has_client_certificate = local.client_cert_id != null && local.client_cert_id != ""
    }

    enforce {
        condition     = local.has_client_certificate
        error_message = "API Gateway stage must have a client certificate configured for backend authentication. Configure 'client_certificate_id' attribute to reference an aws_api_gateway_client_certificate resource"
    }
}
