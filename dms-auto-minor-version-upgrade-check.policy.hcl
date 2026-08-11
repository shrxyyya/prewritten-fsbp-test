# Copyright IBM Corp. 2026

# DMS replication instances should have automatic minor version upgrade enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "dms-auto-minor-version-upgrade-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_dms_replication_instance" "auto_minor_version_upgrade_required" {
    enforcement_level = input.dms-auto-minor-version-upgrade-check-enforcement-level
    locals {
        # Safely access auto_minor_version_upgrade attribute with default false
        auto_upgrade_enabled = core::try(attrs.auto_minor_version_upgrade, false)
    }

    enforce {
        condition = local.auto_upgrade_enabled == true
        error_message = "DMS replication instance must have automatic minor version upgrade enabled. This ensures the instance receives minor engine upgrades automatically during maintenance windows, including bug fixes, security patches, and performance improvements"
    }
}
