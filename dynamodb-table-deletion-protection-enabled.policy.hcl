# Copyright IBM Corp. 2026

# DynamoDB tables should have deletion protection enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.59.0, < 7.0.0"
    }
  }
}

input "dynamodb-table-deletion-protection-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_dynamodb_table" "deletion_protection_enabled" {
    enforcement_level = input.dynamodb-table-deletion-protection-enabled-enforcement-level
    locals {
        # Safe access to deletion_protection_enabled attribute with default false
        deletion_protection = core::try(attrs.deletion_protection_enabled, false)
    }

    enforce {
        condition     = local.deletion_protection == true
        error_message = "DynamoDB table must have deletion protection enabled. Set 'deletion_protection_enabled = true'."
    }
}
