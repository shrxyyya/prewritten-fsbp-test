# Copyright IBM Corp. 2026

# ElastiCache (Redis OSS) replication groups of earlier versions should have Redis OSS AUTH enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elasticache-repl-grp-redis-auth-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_elasticache_replication_group" "redis-auth-enabled" {
    enforcement_level = input.elasticache-repl-grp-redis-auth-enabled-enforcement-level
    filter = core::try(attrs.transit_encryption_enabled, false) == true && core::try(attrs.engine, "redis") == "redis"

    locals {
        engine_version = core::try(attrs.engine_version, "")
        engine_version_condition = local.engine_version != "" ? core::parseint(core::split(".", local.engine_version)[0], 10) >= 6 : true
    }

    enforce {
        condition = core::try(attrs.auth_token, "") != "" && local.engine_version_condition
        error_message = "ElastiCache replication groups should have authentication enabled"
    }
}