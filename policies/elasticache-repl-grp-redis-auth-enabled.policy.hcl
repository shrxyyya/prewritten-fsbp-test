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
  type    = string
  default = "advisory"
}

resource_policy "aws_elasticache_replication_group" "redis_auth_enabled" {
  enforcement_level = input.elasticache-repl-grp-redis-auth-enabled-enforcement-level
  filter = core::try(attrs.engine_version, null) != null && core::try(attrs.engine_version, "") != ""

  locals {
    engine_version = core::try(attrs.engine_version, "")
    is_old_version = core::try(core::semverconstraint(local.engine_version, "< 6.0.0"), false)
    auth_token     = core::try(attrs.auth_token, null)
    auth_token_set = local.auth_token != null && local.auth_token != ""
    is_compliant   = !local.is_old_version || local.auth_token_set
  }

  enforce {
    condition     = local.is_compliant
    error_message = "Attribute 'auth_token' must be set when attribute 'engine_version' < 6.0 for 'aws_elasticache_replication_group' resources."
  }
}
