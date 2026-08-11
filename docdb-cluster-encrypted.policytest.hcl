# Copyright IBM Corp. 2026

policytest {
    targets = [
        "docdb-cluster-encrypted.policy.hcl"
    ]
}

# Test 1: PASS - Encryption enabled, no KMS key arns input provided, no kms_key_id
resource "aws_docdb_cluster" "pass_encrypted_no_input_no_key" {
  attrs = {
    cluster_identifier = "docdb-encrypted-no-key"
    storage_encrypted  = true
    master_username    = "admin"
    engine             = "docdb"
  }
}

# Test 2: PASS - Encryption enabled, no KMS key arns input provided, with kms_key_id
resource "aws_docdb_cluster" "pass_encrypted_no_input_with_key" {
  attrs = {
    cluster_identifier = "docdb-encrypted-with-key"
    storage_encrypted  = true
    kms_key_id         = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    master_username    = "admin"
    engine             = "docdb"
  }
}

# Test 3: FAIL - Encryption disabled
resource "aws_docdb_cluster" "fail_encryption_disabled" {
  expect_failure = true
  attrs = {
    cluster_identifier = "docdb-no-encryption"
    storage_encrypted  = false
    master_username    = "admin"
    engine             = "docdb"
  }
}

# Test 4: FAIL - Missing storage_encrypted (defaults to false)
resource "aws_docdb_cluster" "fail_missing_storage_encrypted" {
  expect_failure = true
  attrs = {
    cluster_identifier = "docdb-missing-encryption"
    master_username    = "admin"
    engine             = "docdb"
  }
}
