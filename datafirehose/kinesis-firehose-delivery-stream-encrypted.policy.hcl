# Copyright IBM Corp. 2026

# Firehose delivery streams should be encrypted at rest

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "kinesis-firehose-delivery-stream-encrypted-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_kinesis_firehose_delivery_stream" "encryption_at_rest_required" {
    enforcement_level = input.kinesis-firehose-delivery-stream-encrypted-enforcement-level
    locals {
        # Check if server_side_encryption block exists and is enabled
        sse_block = core::try(attrs.server_side_encryption, null)
        sse_enabled = local.sse_block != null ? core::try(local.sse_block[0].enabled, false) : false
        
        # Check if kinesis stream is configured as source (exception case)
        has_kinesis_source = core::try(attrs.kinesis_source_configuration, null) != null
    }

    # Skip enforcement if Kinesis stream is the source (exception case)
    filter = !local.has_kinesis_source

    enforce {
        condition = local.sse_enabled == true
        error_message = "Firehose delivery stream must have server-side encryption enabled. Configure the 'server_side_encryption' block with 'enabled = true' to encrypt data at rest"
    }
}
