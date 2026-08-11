# Copyright IBM Corp. 2026

# Amazon EMR block public access setting should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.59.0, < 7.0.0"
    }
  }
}

input "emr-block-public-access-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_emr_block_public_access_configuration" "block-public-access" {
    enforcement_level = input.emr-block-public-access-enforcement-level
    locals {
        block_security_group_enabled = core::try(attrs.block_public_security_group_rules, true)
        is_permitted_range = local.block_security_group_enabled ? (core::try(attrs.permitted_public_security_group_rule_range[0].min_range, 0) == 22 && core::try(attrs.permitted_public_security_group_rule_range[0].max_range, 0) == 22) : false
    }

    enforce {
        condition = local.block_security_group_enabled && local.is_permitted_range
        error_message = "The EMR block public access configuration does not have the correct settings"
    }
}
