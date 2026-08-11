# Copyright IBM Corp. 2026

policytest {
    targets = [
        "docdb-cluster-backup-retention-check.policy.hcl"
    ]
}

# Test 1: PASS - Backup retention period equals default minimum (7 days)
resource "aws_docdb_cluster" "pass_retention_equals_default" {
  attrs = {
    cluster_identifier       = "docdb-retention-7"
    backup_retention_period  = 7
    master_username          = "admin"
    engine                   = "docdb"
  }
}

# Test 2: PASS - Backup retention period greater than default minimum (14 days)
resource "aws_docdb_cluster" "pass_retention_14_days" {
  attrs = {
    cluster_identifier       = "docdb-retention-14"
    backup_retention_period  = 14
    master_username          = "admin"
    engine                   = "docdb"
  }
}

# Test 3: PASS - Backup retention period at maximum (35 days)
resource "aws_docdb_cluster" "pass_retention_max" {
  attrs = {
    cluster_identifier       = "docdb-retention-35"
    backup_retention_period  = 35
    master_username          = "admin"
    engine                   = "docdb"
  }
}

# Test 4: FAIL - Backup retention period less than default minimum (6 days)
resource "aws_docdb_cluster" "fail_retention_6_days" {
  expect_failure = true
  attrs = {
    cluster_identifier       = "docdb-retention-6"
    backup_retention_period  = 6
    master_username          = "admin"
    engine                   = "docdb"
  }
}

# Test 5: FAIL - Backup retention period much less than default minimum (1 day)
resource "aws_docdb_cluster" "fail_retention_1_day" {
  expect_failure = true
  attrs = {
    cluster_identifier       = "docdb-retention-1"
    backup_retention_period  = 1
    master_username          = "admin"
    engine                   = "docdb"
  }
}

# Test 6: FAIL - Backup retention period is 0
resource "aws_docdb_cluster" "fail_retention_0" {
  expect_failure = true
  attrs = {
    cluster_identifier       = "docdb-retention-0"
    backup_retention_period  = 0
    master_username          = "admin"
    engine                   = "docdb"
  }
}

# Test 7: FAIL - Missing backup_retention_period (defaults to 1, less than default minimum 7)
resource "aws_docdb_cluster" "fail_missing_retention" {
  expect_failure = true
  attrs = {
    cluster_identifier       = "docdb-missing-retention"
    master_username          = "admin"
    engine                   = "docdb"
  }
}
