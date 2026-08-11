# Copyright IBM Corp. 2026

policytest {
  targets = [
    "dax-tls-endpoint-encryption.policy.hcl"
  ]
}

# Pass case: DAX cluster with TLS encryption enabled
resource "aws_dax_cluster" "pass_tls_enabled" {
  attrs = {
    cluster_name                      = "compliant-dax-cluster"
    iam_role_arn                      = "arn:aws:iam::123456789012:role/dax-role"
    node_type                         = "dax.r4.large"
    replication_factor                = 3
    cluster_endpoint_encryption_type  = "TLS"
  }
}

# Fail case: DAX cluster with encryption type set to NONE
resource "aws_dax_cluster" "fail_encryption_none" {
  expect_failure = true
  attrs = {
    cluster_name                      = "non-compliant-dax-cluster"
    iam_role_arn                      = "arn:aws:iam::123456789012:role/dax-role"
    node_type                         = "dax.r4.large"
    replication_factor                = 3
    cluster_endpoint_encryption_type  = "NONE"
  }
}

# Fail case: DAX cluster without encryption type specified (defaults to NONE)
resource "aws_dax_cluster" "fail_encryption_missing" {
  expect_failure = true
  attrs = {
    cluster_name       = "non-compliant-dax-cluster-missing"
    iam_role_arn       = "arn:aws:iam::123456789012:role/dax-role"
    node_type          = "dax.r4.large"
    replication_factor = 3
    # cluster_endpoint_encryption_type is not specified (defaults to NONE)
  }
}