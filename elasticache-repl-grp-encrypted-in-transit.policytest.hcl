# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elasticache-repl-grp-encrypted-in-transit.policy.hcl"
    ]
}

# Test 1: PASS - ElastiCache replication group with transit_encryption_enabled = true
resource "aws_elasticache_replication_group" "compliant" {
  attrs = {
    replication_group_id = "compliant-cluster"
    description = "Compliant ElastiCache cluster with encryption in transit"
    node_type = "cache.t3.micro"
    engine = "redis"
    engine_version = "7.0"
    transit_encryption_enabled = true
  }
}

# Test 2: FAIL - ElastiCache replication group with transit_encryption_enabled = false
resource "aws_elasticache_replication_group" "non_compliant" {
  expect_failure = true
  attrs = {
    replication_group_id = "non-compliant-cluster"
    description = "Non-compliant ElastiCache cluster without encryption in transit"
    node_type = "cache.t3.micro"
    engine = "redis"
    engine_version = "7.0"
    transit_encryption_enabled = false
  }
}

# Test 3: FAIL - ElastiCache replication group without transit_encryption_enabled attribute
resource "aws_elasticache_replication_group" "missing_attribute" {
  expect_failure = true
  attrs = {
    replication_group_id = "missing-encryption-cluster"
    description = "ElastiCache cluster without transit_encryption_enabled attribute"
    node_type = "cache.t3.micro"
    engine = "redis"
    engine_version = "7.0"
  }
}