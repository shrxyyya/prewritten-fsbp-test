# Copyright IBM Corp. 2026

policytest {
    targets = [
        "efs-automatic-backups-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Backup policy with status ENABLED
resource "aws_efs_backup_policy" "pass_backup_enabled" {
  attrs = {
    file_system_id = "fs-12345678"
    backup_policy = [
      {
        status = "ENABLED"
      }
    ]
  }
}

# Test 2: FAIL - Backup policy with status DISABLED
resource "aws_efs_backup_policy" "fail_backup_disabled" {
  expect_failure = true
  attrs = {
    file_system_id = "fs-12345678"
    backup_policy = [
      {
        status = "DISABLED"
      }
    ]
  }
}

# Test 3: FAIL - Empty backup_policy list (no backup configured)
resource "aws_efs_backup_policy" "fail_empty_backup_policy" {
  expect_failure = true
  attrs = {
    file_system_id = "fs-12345678"
    backup_policy = []
  }
}

# Test 4: FAIL - Backup policy with missing status (defaults to DISABLED)
resource "aws_efs_backup_policy" "fail_missing_status" {
  expect_failure = true
  attrs = {
    file_system_id = "fs-33333333"
    backup_policy = [
      {
        # status field omitted - should default to DISABLED
      }
    ]
  }
}
