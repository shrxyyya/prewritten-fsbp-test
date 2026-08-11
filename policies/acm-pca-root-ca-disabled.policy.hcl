# Copyright IBM Corp. 2026

# AWS Private CA root certificate authority should be disabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "acm-pca-root-ca-disabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_acmpca_certificate_authority" "root_ca_disabled" {
    enforcement_level = input.acm-pca-root-ca-disabled-enforcement-level
    // Filter to only evaluate root certificate authorities
    // Only check CAs where type is explicitly set to "ROOT"
    filter = core::try(attrs.type, "SUBORDINATE") == "ROOT"

    locals {
        // Safe access to the enabled attribute with default of true (provider default)
        is_enabled = core::try(attrs.enabled, true)
    }

    enforce {
        condition = local.is_enabled == false
        error_message = "Root CA must be disabled. Root CAs should only be used to issue certificates for intermediate CAs and should be stored securely. Set 'enabled = false' to comply with this control"
    }
}
