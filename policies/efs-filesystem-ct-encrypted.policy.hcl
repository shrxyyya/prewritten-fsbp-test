# Copyright IBM Corp. 2026

# EFS file systems should be encrypted at rest

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "efs-filesystem-ct-encrypted-enforcement-level" {
  type = string
  default = "advisory"
}

input "efs_kms_key_arns" {
    type = string
    default = ""
}

resource_policy "aws_efs_file_system" "encryption_at_rest" {
    enforcement_level = input.efs-filesystem-ct-encrypted-enforcement-level
    locals {
        is_encrypted = core::try(attrs.encrypted, false)
        kms_key_id = core::try(attrs.kms_key_id, "")

        has_efs_input = input.efs_kms_key_arns != ""
        valid_key = local.has_efs_input ? core::contains(core::split(",", input.efs_kms_key_arns), local.kms_key_id) : true
    }

    enforce {
        condition = local.is_encrypted == true && local.valid_key
        error_message = "EFS file system does not have encryption at rest enabled. Set 'encrypted = true' in the resource configuration to comply with the policy"
    }
}
