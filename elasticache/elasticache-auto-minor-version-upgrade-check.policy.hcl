# Copyright IBM Corp. 2026

# ElastiCache clusters should have automatic minor version upgrades enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0, < 7.0.0"
    }
  }
}

input "elasticache-auto-minor-version-upgrade-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_elasticache_cluster" "auto-minor-version-upgrade-check" {
    enforcement_level = input.elasticache-auto-minor-version-upgrade-check-enforcement-level
    filter = (core::try(attrs.engine, "") == "redis" || core::try(attrs.engine, "") == "valkey")

    locals {
        engine_version = core::try(attrs.engine_version, "")
        engine_version_condition = local.engine_version != "" ? core::parseint(core::split(".", local.engine_version)[0], 10) >= 6 : true
    }

    enforce {
        condition = core::try(attrs.auto_minor_version_upgrade, true) && local.engine_version_condition
        error_message = "ElastiCache clusters should have automatic minor version upgrades enabled"
    }
}