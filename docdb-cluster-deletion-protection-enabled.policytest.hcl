# Copyright IBM Corp. 2026

policytest {
    targets = [
        "docdb-cluster-deletion-protection-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Deletion protection enabled (true)
resource "aws_docdb_cluster" "pass_deletion_protection_enabled" {
  attrs = {
    cluster_identifier      = "docdb-protected"
    deletion_protection     = true
    master_username         = "admin"
    engine                  = "docdb"
  }
}

# Test 2: FAIL - Deletion protection disabled (false)
resource "aws_docdb_cluster" "fail_deletion_protection_disabled" {
  expect_failure = true
  attrs = {
    cluster_identifier      = "docdb-not-protected"
    deletion_protection     = false
    master_username         = "admin"
    engine                  = "docdb"
  }
}

# Test 3: FAIL - Missing deletion_protection (defaults to false)
resource "aws_docdb_cluster" "fail_missing_deletion_protection" {
  expect_failure = true
  attrs = {
    cluster_identifier      = "docdb-missing-protection"
    master_username         = "admin"
    engine                  = "docdb"
  }
}
