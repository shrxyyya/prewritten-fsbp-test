# Copyright IBM Corp. 2026

# Amazon DocumentDB clusters should have an adequate backup retention period

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "docdb-cluster-backup-retention-check-enforcement-level" {
  type = string
  default = "advisory"
}

input "docdb_min_backup_retention_period" {
    type = number
    default = 7
}

resource_policy "aws_docdb_cluster" "backup-retention-period" {
    enforcement_level = input.docdb-cluster-backup-retention-check-enforcement-level
    enforce {
        condition = input.docdb_min_backup_retention_period >= 1 && input.docdb_min_backup_retention_period <= 35 && core::try(attrs.backup_retention_period, 1) >= input.docdb_min_backup_retention_period
        error_message = "The backup retention period for the DocumentDB cluster is less than the minimum required"
    }
}