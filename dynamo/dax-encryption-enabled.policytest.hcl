# Copyright IBM Corp. 2026

policytest {
  targets = [
    "dax-encryption-enabled.policy.hcl"
  ]
}
# Test 1: PASS - DAX cluster with encryption enabled
resource "aws_dax_cluster" "pass_encryption_enabled" {
  attrs = {
    cluster_name       = "compliant-cluster"
    iam_role_arn      = "arn:aws:iam::123456789012:role/dax-role"
    node_type         = "dax.t3.small"
    replication_factor = 3
    server_side_encryption = [
      {
        enabled = true
      }
    ]
  }
}

# Test 2: FAIL - DAX cluster with encryption explicitly disabled
resource "aws_dax_cluster" "fail_encryption_disabled" {
  expect_failure = true
  attrs = {
    cluster_name       = "non-compliant-cluster"
    iam_role_arn      = "arn:aws:iam::123456789012:role/dax-role"
    node_type         = "dax.t3.small"
    replication_factor = 3
    server_side_encryption = [
      {
        enabled = false
      }
    ]
  }
}

# Test 3: FAIL - DAX cluster without server_side_encryption block
resource "aws_dax_cluster" "fail_no_encryption_block" {
  expect_failure = true
  attrs = {
    cluster_name       = "no-encryption-cluster"
    iam_role_arn      = "arn:aws:iam::123456789012:role/dax-role"
    node_type         = "dax.t3.small"
    replication_factor = 3
  }
}

# Test 4: FAIL - DAX cluster with empty server_side_encryption block (enabled defaults to false)
resource "aws_dax_cluster" "fail_encryption_not_specified" {
  expect_failure = true
  attrs = {
    cluster_name       = "default-encryption-cluster"
    iam_role_arn      = "arn:aws:iam::123456789012:role/dax-role"
    node_type         = "dax.t3.small"
    replication_factor = 3
    server_side_encryption = [
      {}
    ]
  }
}