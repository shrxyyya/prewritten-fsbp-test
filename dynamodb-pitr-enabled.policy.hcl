# Copyright IBM Corp. 2026

# dynamodb-pitr-enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "dynamodb-pitr-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_dynamodb_table" "pitr_enabled" {
  enforcement_level = input.dynamodb-pitr-enabled-enforcement-level
  locals {
    # Safely extract the point_in_time_recovery configuration
    pitr_config = core::try(attrs.point_in_time_recovery, [])
    
    # Check if PITR block exists and has content
    has_pitr_block = core::length(local.pitr_config) > 0
    
    # Extract enabled status (default to false if not specified)
    pitr_enabled = local.has_pitr_block ? core::try(local.pitr_config[0].enabled, false) : false
  }

  enforce {
    condition     = local.pitr_enabled == true
    error_message = "DynamoDB table must have point-in-time recovery enabled. Add a 'point_in_time_recovery' block with 'enabled = true' to comply with AWS Security Hub control DynamoDB.2"
  }
}
