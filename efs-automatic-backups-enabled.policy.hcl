# Copyright IBM Corp. 2026

# EFS file systems should have automatic backups enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "efs-automatic-backups-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_efs_backup_policy" "automatic_backups_enabled" {
    enforcement_level = input.efs-automatic-backups-enabled-enforcement-level
    locals {
        backup_policy_list = core::try(attrs.backup_policy, [])
        has_backup_policy = core::length(local.backup_policy_list) > 0
        backup_status = local.has_backup_policy ? core::try(local.backup_policy_list[0].status, "DISABLED") : "DISABLED"
    }

    enforce {
        condition = local.has_backup_policy && local.backup_status == "ENABLED"
        error_message = "EFS backup policy does not have automatic backups enabled. The backup_policy.status must be set to 'ENABLED' to ensure data protection and recovery capabilities"
    }
}
