# Copyright IBM Corp. 2026

# AWS Backup recovery points should be encrypted at rest

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.1.0, < 7.0.0"
    }
  }
}

input "backup-recovery-point-encrypted-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_backup_framework" "backup_recovery_point_encrypted" {
  enforcement_level = input.backup-recovery-point-encrypted-enforcement-level

  locals {
    controls = [for c in core::try(attrs.control, []) : c]
    control_names = local.controls != [] ? [for c in local.controls : core::try(c.name, "")] : []
    has_encryption_control = core::contains(local.control_names, "BACKUP_RECOVERY_POINT_ENCRYPTED")
    }
  enforce {
    condition     = local.has_encryption_control
    error_message = "AWS Backup Framework Recovery Point must be encrypted at rest. Add a control block with name = 'BACKUP_RECOVERY_POINT_ENCRYPTED'"
  }
}
