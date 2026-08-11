# Copyright IBM Corp. 2026

# Amazon DocumentDB clusters should be encrypted at rest

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "docdb-cluster-encrypted-enforcement-level" {
  type = string
  default = "advisory"
}

input "docdb_kms_key_arns" {
    type = string
    default = ""
}

resource_policy "aws_docdb_cluster" "encrypted-at-rest" {
    enforcement_level = input.docdb-cluster-encrypted-enforcement-level
    locals {
        has_encryption = core::try(attrs.storage_encrypted, false)
        kms_key_arn = local.has_encryption ? core::try(attrs.kms_key_id, "") : ""
        kms_key_arns_provided = input.docdb_kms_key_arns != ""
        valid_kms_key_arn = local.kms_key_arns_provided ? (local.kms_key_arn != "" ? core::contains(core::split(",", input.docdb_kms_key_arns), local.kms_key_arn) : true) : true
    }

    enforce {
        condition = local.has_encryption && local.valid_kms_key_arn
        error_message = "DocumentDB cluster either does not have encryption enabled or uses invalid KMS key"
    }
}