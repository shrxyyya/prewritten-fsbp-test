# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elasticache-auto-minor-version-upgrade-check.policy.hcl"
    ]
}

# Test 1: PASS - Redis cluster version 6.0 with auto minor version upgrade enabled
resource "aws_elasticache_cluster" "pass_redis_6_enabled" {
  attrs = {
    cluster_id                  = "redis-6-enabled"
    engine                      = "redis"
    engine_version              = "6.0"
    auto_minor_version_upgrade  = true
  }
}

# Test 2: PASS - Valkey cluster version 7.0 with auto minor version upgrade enabled
resource "aws_elasticache_cluster" "pass_valkey_7_enabled" {
  attrs = {
    cluster_id                  = "valkey-7-enabled"
    engine                      = "valkey"
    engine_version              = "7.0"
    auto_minor_version_upgrade  = true
  }
}

# Test 3: PASS - Missing auto_minor_version_upgrade defaults to true
resource "aws_elasticache_cluster" "pass_missing_auto_minor_upgrade" {
  attrs = {
    cluster_id      = "redis-default-auto-upgrade"
    engine          = "redis"
    engine_version  = "6.2"
  }
}

# Test 4: FAIL - Redis cluster version 6.0 with auto minor version upgrade disabled
resource "aws_elasticache_cluster" "fail_redis_6_disabled" {
  expect_failure = true
  attrs = {
    cluster_id                  = "redis-6-disabled"
    engine                      = "redis"
    engine_version              = "6.0"
    auto_minor_version_upgrade  = false
  }
}

# Test 5: FAIL - Valkey cluster version 7.0 with auto minor version upgrade disabled
resource "aws_elasticache_cluster" "fail_valkey_7_disabled" {
  expect_failure = true
  attrs = {
    cluster_id                  = "valkey-7-disabled"
    engine                      = "valkey"
    engine_version              = "7.0"
    auto_minor_version_upgrade  = false
  }
}

# Test 6: PASS - Non-Redis and non-Valkey engine excluded by filter
resource "aws_elasticache_cluster" "pass_non_matching_engine" {
  attrs = {
    cluster_id                  = "memcached-excluded"
    engine                      = "memcached"
    engine_version              = "1.6.0"
    auto_minor_version_upgrade  = false
  }
}

# Test 7: PASS - Missing engine_version with auto minor version upgrade enabled
resource "aws_elasticache_cluster" "pass_missing_engine_version" {
  attrs = {
    cluster_id                  = "missing-version"
    engine                      = "redis"
    auto_minor_version_upgrade  = true
  }
}

# Test 8: FAIL - Redis cluster version below 6.0
resource "aws_elasticache_cluster" "pass_redis_below_6" {
  expect_failure = true
  attrs = {
    cluster_id                  = "redis-5-excluded"
    engine                      = "redis"
    engine_version              = "5.0.6"
    auto_minor_version_upgrade  = false
  }
}