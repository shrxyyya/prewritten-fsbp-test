# Copyright IBM Corp. 2026

# ElastiCache replication groups should have automatic failover enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elasticache-repl-grp-auto-failover-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_elasticache_replication_group" "auto-failover-enabled" {
    enforcement_level = input.elasticache-repl-grp-auto-failover-enabled-enforcement-level
    enforce {
        condition = core::try(attrs.automatic_failover_enabled, false) == true ? core::try(attrs.num_cache_clusters, 1) >= 2 : false
        error_message = "ElastiCache replication groups should have automatic failover enabled"
    }
}
