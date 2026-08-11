# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elasticache-redis-cluster-automatic-backup-check.policy.hcl"
    ]
}

# Test 1: PASS - Cache cluster with snapshot retention limit equal to threshold
resource "aws_elasticache_cluster" "pass_cluster_retention_15" {
  attrs = {
    cluster_id                = "redis-cluster-backup-15"
    engine                    = "redis"
    node_type                 = "cache.t3.small"
    snapshot_retention_limit  = 15
  }
}

# Test 2: PASS - Cache cluster with snapshot retention limit above threshold
resource "aws_elasticache_cluster" "pass_cluster_retention_20" {
  attrs = {
    cluster_id                = "redis-cluster-backup-20"
    engine                    = "redis"
    node_type                 = "cache.m6g.large"
    snapshot_retention_limit  = 20
  }
}

# Test 3: FAIL - Cache cluster with snapshot retention limit below threshold
resource "aws_elasticache_cluster" "fail_cluster_retention_1" {
  expect_failure = true
  attrs = {
    cluster_id                = "redis-cluster-backup-1"
    engine                    = "redis"
    node_type                 = "cache.t3.micro"
    snapshot_retention_limit  = 1
  }
}

# Test 4: FAIL - Cache cluster with backups disabled
resource "aws_elasticache_cluster" "fail_cluster_retention_0" {
  expect_failure = true
  attrs = {
    cluster_id                = "redis-cluster-backup-disabled"
    engine                    = "redis"
    node_type                 = "cache.t3.micro"
    snapshot_retention_limit  = 0
  }
}

# Test 5: FAIL - Cache cluster missing snapshot_retention_limit defaults to 0
resource "aws_elasticache_cluster" "fail_cluster_missing_retention" {
  expect_failure = true
  attrs = {
    cluster_id = "redis-cluster-backup-missing"
    engine     = "redis"
    node_type  = "cache.t3.micro"
  }
}

# Test 6: PASS - Cache cluster with non-Redis engine excluded by filter
resource "aws_elasticache_cluster" "pass_cluster_non_redis_engine" {
  attrs = {
    cluster_id                = "memcached-cluster"
    engine                    = "memcached"
    node_type                 = "cache.t3.micro"
    snapshot_retention_limit  = 0
  }
}

# Test 7: PASS - Replication group with snapshot retention limit equal to threshold
resource "aws_elasticache_replication_group" "pass_rg_retention_15" {
  attrs = {
    replication_group_id      = "redis-backup-15"
    engine                    = "redis"
    node_type                 = "cache.t3.small"
    snapshot_retention_limit  = 15
  }
}

# Test 8: PASS - Replication group with snapshot retention limit above threshold
resource "aws_elasticache_replication_group" "pass_rg_retention_20" {
  attrs = {
    replication_group_id      = "redis-backup-20"
    engine                    = "redis"
    node_type                 = "cache.m6g.large"
    snapshot_retention_limit  = 20
  }
}

# Test 9: FAIL - Replication group with snapshot retention limit below threshold
resource "aws_elasticache_replication_group" "fail_rg_retention_1" {
  expect_failure = true
  attrs = {
    replication_group_id      = "redis-backup-1"
    engine                    = "redis"
    node_type                 = "cache.t3.micro"
    snapshot_retention_limit  = 1
  }
}

# Test 10: FAIL - Replication group with backups disabled
resource "aws_elasticache_replication_group" "fail_rg_retention_0" {
  expect_failure = true
  attrs = {
    replication_group_id      = "redis-backup-disabled"
    engine                    = "redis"
    node_type                 = "cache.t3.micro"
    snapshot_retention_limit  = 0
  }
}

# Test 11: FAIL - Replication group missing snapshot_retention_limit defaults to 0
resource "aws_elasticache_replication_group" "fail_rg_missing_retention" {
  expect_failure = true
  attrs = {
    replication_group_id = "redis-backup-missing"
    engine               = "redis"
    node_type            = "cache.t3.micro"
  }
}

# Test 12: PASS - Replication group with non-Redis engine excluded by filter
resource "aws_elasticache_replication_group" "pass_rg_non_redis_engine" {
  attrs = {
    replication_group_id      = "memcached-group"
    engine                    = "memcached"
    node_type                 = "cache.t3.micro"
    snapshot_retention_limit  = 0
  }
}
