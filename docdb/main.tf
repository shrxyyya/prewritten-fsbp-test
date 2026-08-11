terraform {
  required_version = ">= 1.15.0"

  cloud {

    organization = "nagateja-test-org"

    workspaces {
      name = "provider-test"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_kms_key" "docdb" {
  description             = "KMS key for DocumentDB encryption at rest"
  deletion_window_in_days = 7
}

# docdb-cluster-encrypted-in-transit: parameter group with tls=enabled
resource "aws_docdb_cluster_parameter_group" "example" {
  name        = "example-docdb-params"
  family      = "docdb5.0"
  description = "example DocumentDB parameter group"

  parameter {
    name  = "tls"
    value = "enabled"
  }
}

resource "aws_docdb_cluster" "example" {
  cluster_identifier = "example-docdb-cluster"
  engine             = "docdb"
  master_username    = "admin"
  master_password    = "example-password"

  # docdb-cluster-encrypted: storage encryption with KMS key
  storage_encrypted = true
  kms_key_id        = aws_kms_key.docdb.arn

  # docdb-cluster-deletion-protection-enabled: deletion protection required
  deletion_protection = true

  # docdb-cluster-backup-retention-check: minimum 7 days retention
  backup_retention_period = 7

  # docdb-cluster-audit-logging-enabled: publish audit logs to CloudWatch
  enabled_cloudwatch_logs_exports = ["audit"]

  # docdb-cluster-encrypted-in-transit: reference the parameter group with tls=enabled
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.example.name
}
