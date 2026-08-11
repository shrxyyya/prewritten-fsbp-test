# Copyright IBM Corp. 2026

policytest {
    targets = [
        "efs-in-backup-plan.policy.hcl"
    ]
}

# Test 1: PASS - EFS file system explicitly referenced in backup selection
resource "aws_efs_file_system" "protected" {
  attrs = {
    arn = "arn:aws:elasticfilesystem:us-east-1:123456789012:file-system/fs-12345678"
    encrypted = true
    tags = {
      Name = "protected-efs"
      Environment = "production"
    }
  }
}

resource "aws_backup_selection" "efs_selection" {
  skip = true
  attrs = {
    name = "efs-backup-selection"
    plan_id = "backup-plan-123"
    iam_role_arn = "arn:aws:iam::123456789012:role/AWSBackupRole"
    resources = [
      "arn:aws:elasticfilesystem:us-east-1:123456789012:file-system/fs-12345678"
    ]
  }
}

# Test 2: PASS - EFS file system selected by tags
resource "aws_efs_file_system" "tagged" {
  attrs = {
    arn = "arn:aws:elasticfilesystem:us-east-1:123456789012:file-system/fs-87654321"
    encrypted = true
    tags = {
      Name = "tagged-efs"
      Backup = "true"
      Environment = "production"
    }
  }
}

resource "aws_backup_selection" "tag_selection" {
  skip = true
  attrs = {
    name = "tag-based-selection"
    plan_id = "backup-plan-456"
    iam_role_arn = "arn:aws:iam::123456789012:role/AWSBackupRole"
    selection_tag = [
      {
        type = "STRINGEQUALS"
        key = "Backup"
        value = "true"
      }
    ]
  }
}

# Test 3: FAIL - EFS file system not in any backup plan
resource "aws_efs_file_system" "unprotected" {
  expect_failure = true
  attrs = {
    arn = "arn:aws:elasticfilesystem:us-east-1:123456789012:file-system/fs-99999999"
    encrypted = true
    tags = {
      Name = "unprotected-efs"
      Environment = "development"
    }
  }
}

resource "aws_backup_selection" "other_selection" {
  skip = true
  attrs = {
    name = "other-backup-selection"
    plan_id = "backup-plan-789"
    iam_role_arn = "arn:aws:iam::123456789012:role/AWSBackupRole"
    resources = [
      "arn:aws:elasticfilesystem:us-east-1:123456789012:file-system/fs-11111111"
    ]
  }
}

# Test 4: PASS - EFS file system with backup policy enabled
resource "aws_efs_file_system" "with_backup_policy" {
  attrs = {
    id = "fs-backup-policy-enabled"
    arn = "arn:aws:elasticfilesystem:us-east-1:123456789012:file-system/fs-backup-policy-enabled"
    encrypted = true
    tags = {
      Name = "efs-with-backup-policy"
      Environment = "production"
    }
  }
}

resource "aws_efs_backup_policy" "backup_policy_enabled" {
  skip = true
  attrs = {
    file_system_id = "fs-backup-policy-enabled"
    backup_policy = {
      status = "ENABLED"
    }
  }
}

# Test 5: FAIL - EFS file system with backup policy disabled
resource "aws_efs_file_system" "with_disabled_backup_policy" {
  expect_failure = true
  attrs = {
    id = "fs-backup-policy-disabled"
    arn = "arn:aws:elasticfilesystem:us-east-1:123456789012:file-system/fs-backup-policy-disabled"
    encrypted = true
    tags = {
      Name = "efs-with-disabled-backup-policy"
      Environment = "development"
    }
  }
}

resource "aws_efs_backup_policy" "backup_policy_disabled" {
  skip = true
  attrs = {
    file_system_id = "fs-backup-policy-disabled"
    backup_policy = {
      status = "DISABLED"
    }
  }
}
