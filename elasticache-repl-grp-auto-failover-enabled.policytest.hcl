# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elasticache-repl-grp-auto-failover-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Auto failover enabled with 2 cache clusters
resource "aws_elasticache_replication_group" "pass_auto_failover_2_clusters" {
  attrs = {
    replication_group_id      = "redis-auto-failover-2"
    automatic_failover_enabled = true
    num_cache_clusters        = 2
  }
}

# Test 2: PASS - Auto failover enabled with 3 cache clusters
resource "aws_elasticache_replication_group" "pass_auto_failover_3_clusters" {
  attrs = {
    replication_group_id      = "redis-auto-failover-3"
    automatic_failover_enabled = true
    num_cache_clusters        = 3
  }
}

# Test 3: FAIL - Auto failover enabled but only 1 cache cluster
resource "aws_elasticache_replication_group" "fail_auto_failover_1_cluster" {
  expect_failure = true
  attrs = {
    replication_group_id      = "redis-auto-failover-1"
    automatic_failover_enabled = true
    num_cache_clusters        = 1
  }
}

# Test 4: FAIL - Auto failover disabled with 2 cache clusters
resource "aws_elasticache_replication_group" "fail_auto_failover_disabled_2_clusters" {
  expect_failure = true
  attrs = {
    replication_group_id      = "redis-no-auto-failover-2"
    automatic_failover_enabled = false
    num_cache_clusters        = 2
  }
}

# Test 5: FAIL - Auto failover disabled with 1 cache cluster
resource "aws_elasticache_replication_group" "fail_auto_failover_disabled_1_cluster" {
  expect_failure = true
  attrs = {
    replication_group_id      = "redis-no-auto-failover-1"
    automatic_failover_enabled = false
    num_cache_clusters        = 1
  }
}

# Test 6: FAIL - Missing auto_failover_enabled (defaults to false)
resource "aws_elasticache_replication_group" "fail_missing_auto_failover" {
  expect_failure = true
  attrs = {
    replication_group_id      = "redis-missing-auto-failover"
    num_cache_clusters        = 2
  }
}

# Test 7: FAIL - Auto failover enabled but missing num_cache_clusters (defaults to 1)
resource "aws_elasticache_replication_group" "fail_auto_failover_missing_num_clusters" {
  expect_failure = true
  attrs = {
    replication_group_id      = "redis-auto-failover-missing-num"
    automatic_failover_enabled = true
  }
}

# Test 8: FAIL - Both auto_failover_enabled and num_cache_clusters missing
resource "aws_elasticache_replication_group" "fail_both_missing" {
  expect_failure = true
  attrs = {
    replication_group_id      = "redis-both-missing"
  }
}

# Test 9: FAIL - Auto failover enabled with 0 cache clusters
resource "aws_elasticache_replication_group" "fail_auto_failover_0_clusters" {
  expect_failure = true
  attrs = {
    replication_group_id      = "redis-auto-failover-0"
    automatic_failover_enabled = true
    num_cache_clusters        = 0
  }
}
