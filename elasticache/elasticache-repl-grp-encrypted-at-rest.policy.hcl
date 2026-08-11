# Copyright IBM Corp. 2026

# ElastiCache replication groups should be encrypted at rest

input "approved_kms_keys" {
    type = string
    default = ""
}

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elasticache-repl-grp-encrypted-at-rest-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_elasticache_replication_group" "elasticache-rg-encrypted-at-rest" {
    enforcement_level = input.elasticache-repl-grp-encrypted-at-rest-enforcement-level
    locals {
        engine = core::try(attrs.engine, "redis")
        at_rest_encryption = (local.engine == "redis" && core::try(attrs.at_rest_encryption_enabled, false)) || (local.engine == "valkey" && core::try(attrs.at_rest_encryption_enabled, true))
    }

    enforce {
        condition = local.at_rest_encryption && (input.approved_kms_keys != "" && core::try(attrs.kms_key_id, "") != "" ? core::contains(core::split(",", input.approved_kms_keys), core::try(attrs.kms_key_id, "")) : true)
        error_message = "ElastiCache replication group is not encrypted at rest"
    }
}