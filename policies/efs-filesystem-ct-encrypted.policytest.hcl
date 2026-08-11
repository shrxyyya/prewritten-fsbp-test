# Copyright IBM Corp. 2026

policytest {
    targets = [
        "efs-filesystem-ct-encrypted.policy.hcl"
    ]
}

# Test 1: PASS - EFS file system with encryption explicitly enabled
resource "aws_efs_file_system" "encrypted" {
  attrs = {
    encrypted = true
  }
}

# Test 2: PASS - EFS file system with encryption enabled and custom KMS key
resource "aws_efs_file_system" "encrypted_kms" {
  attrs = {
    encrypted = true
    kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
}

# Test 3: FAIL - EFS file system with encryption explicitly disabled
resource "aws_efs_file_system" "not_encrypted" {
  expect_failure = true
  attrs = {
    encrypted = false
  }
}

# Test 4: FAIL - EFS file system without encryption attribute specified (defaults to false)
resource "aws_efs_file_system" "no_encryption_attr" {
  expect_failure = true
  attrs = {
    performance_mode = "generalPurpose"
  }
}
