# Copyright IBM Corp. 2026

# ElastiCache (Redis OSS) clusters should have automatic backups enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elasticache-redis-cluster-automatic-backup-check-enforcement-level" {
  type = string
  default = "advisory"
}

input "snapshot_retention_period" {
    type = number
    default = 15
}

resource_policy "aws_elasticache_cluster" "backup-check"{
    enforcement_level = input.elasticache-redis-cluster-automatic-backup-check-enforcement-level
    filter = core::try(attrs.engine, "redis") == "redis"

    locals {
        snapshot_retention_limit = core::try(attrs.snapshot_retention_limit, 0)
    }

    enforce {
        condition = local.snapshot_retention_limit != 0 && local.snapshot_retention_limit >= input.snapshot_retention_period
        error_message = "ElastiCache Redis clusters should have automatic backup turned on"
    }
}

resource_policy "aws_elasticache_replication_group" "redis-backup-check"{
    enforcement_level = input.elasticache-redis-cluster-automatic-backup-check-enforcement-level
    filter = core::try(attrs.engine, "redis") == "redis"

    locals {
        snapshot_retention_limit = core::try(attrs.snapshot_retention_limit, 0)
    }

    enforce {
        condition = local.snapshot_retention_limit != 0 && local.snapshot_retention_limit >= input.snapshot_retention_period
        error_message = "ElastiCache Redis clusters should have automatic backup turned on"
    }
}