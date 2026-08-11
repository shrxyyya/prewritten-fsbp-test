# Copyright IBM Corp. 2026

# DynamoDB Accelerator (DAX) clusters should be encrypted at rest

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "dax-encryption-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_dax_cluster" "encryption_at_rest_required" {
    enforcement_level = input.dax-encryption-enabled-enforcement-level
    locals {
        # Safely access the server_side_encryption block
        # The server_side_encryption attribute is a list of objects (block)
        sse_config = core::try(attrs.server_side_encryption, [])
        
        # Check if the block exists and has at least one element
        has_sse_block = core::length(local.sse_config) > 0
        
        # Check if encryption is enabled (defaults to false if not set)
        encryption_enabled = local.has_sse_block && core::try(local.sse_config[0].enabled, false)
    }

    enforce {
        condition     = local.encryption_enabled == true
        error_message = "DAX cluster must have encryption at rest enabled. Set server_side_encryption.enabled = true in the cluster configuration"
    }
}
