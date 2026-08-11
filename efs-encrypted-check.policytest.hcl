# Copyright IBM Corp. 2026

policytest {
  targets = [
    "efs-encrypted-check.policy.hcl"
  ]
}
# Test 1: PASS - EFS file system with encryption enabled
resource "aws_efs_file_system" "pass_encrypted_true" {
  attrs = {
    encrypted = true
    creation_token = "my-efs"
    performance_mode = "generalPurpose"
    throughput_mode = "bursting"
  }
}

# Test 2: FAIL - EFS file system with encryption explicitly disabled
resource "aws_efs_file_system" "fail_encrypted_false" {
  expect_failure = true
  attrs = {
    encrypted = false
    creation_token = "my-efs-unencrypted"
    performance_mode = "generalPurpose"
    throughput_mode = "bursting"
  }
}

# Test 3: FAIL - EFS file system without encrypted attribute (defaults to false)
resource "aws_efs_file_system" "fail_encrypted_missing" {
  expect_failure = true
  attrs = {
    creation_token = "my-efs-no-encryption-attr"
    performance_mode = "generalPurpose"
    throughput_mode = "bursting"
  }
}