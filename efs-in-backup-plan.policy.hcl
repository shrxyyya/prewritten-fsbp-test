# Copyright IBM Corp. 2026

# Amazon EFS volumes should be in backup plans

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "efs-in-backup-plan-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_efs_file_system" "in_backup_plan" {
  enforcement_level = input.efs-in-backup-plan-enforcement-level
  locals {
    all_selections = core::getresources("aws_backup_selection", {})
    efs_arn = core::try(attrs.arn, "")
    backup_tag = core::try(attrs.tags["Backup"], "")
    has_backup_tag = local.backup_tag == "true"
    in_backup = core::length([for sel in local.all_selections : sel if core::contains(core::try(sel.resources, []), local.efs_arn)]) > 0

    backup_policy = core::getresources("aws_efs_backup_policy", {
        file_system_id = core::try(attrs.id, "")
    })
    has_backup_policy = core::length([
        for policy in local.backup_policy : policy if core::try(policy.backup_policy.status, "DISABLED") == "ENABLED"
    ]) > 0
  }

  enforce {
    condition = local.in_backup || local.has_backup_tag || local.has_backup_policy
    error_message = "EFS file system is not included in any AWS Backup plan. Either add this file system to an aws_backup_selection resource that is associated with an aws_backup_plan (by explicit ARN reference or by tag-based selection), or set backup_policy.status to 'ENABLED'"
  }
}
