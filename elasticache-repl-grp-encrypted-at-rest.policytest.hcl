# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elasticache-repl-grp-encrypted-at-rest.policy.hcl"
    ]
}

# Test 1: PASS - Redis replication group with encryption enabled
resource "aws_elasticache_replication_group" "pass_redis_encrypted" {
  attrs = {
    replication_group_id          = "redis-encrypted"
    engine                        = "redis"
    at_rest_encryption_enabled    = true
  }
}

# Test 2: PASS - Valkey replication group with encryption enabled (explicit)
resource "aws_elasticache_replication_group" "pass_valkey_encrypted_explicit" {
  attrs = {
    replication_group_id          = "valkey-encrypted-explicit"
    engine                        = "valkey"
    at_rest_encryption_enabled    = true
  }
}

# Test 3: PASS - Valkey replication group with missing encryption (defaults to true)
resource "aws_elasticache_replication_group" "pass_valkey_encrypted_default" {
  attrs = {
    replication_group_id          = "valkey-encrypted-default"
    engine                        = "valkey"
  }
}

# Test 4: PASS - Missing engine defaults to redis, encryption enabled
resource "aws_elasticache_replication_group" "pass_default_engine_encrypted" {
  attrs = {
    replication_group_id          = "default-engine-encrypted"
    at_rest_encryption_enabled    = true
  }
}

# Test 5: FAIL - Redis replication group with encryption disabled
resource "aws_elasticache_replication_group" "fail_redis_not_encrypted" {
  expect_failure = true
  attrs = {
    replication_group_id          = "redis-not-encrypted"
    engine                        = "redis"
    at_rest_encryption_enabled    = false
  }
}

# Test 6: FAIL - Redis replication group missing encryption (defaults to false)
resource "aws_elasticache_replication_group" "fail_redis_missing_encryption" {
  expect_failure = true
  attrs = {
    replication_group_id          = "redis-missing-encryption"
    engine                        = "redis"
  }
}

# Test 7: FAIL - Valkey replication group with encryption explicitly disabled
resource "aws_elasticache_replication_group" "fail_valkey_encryption_disabled" {
  expect_failure = true
  attrs = {
    replication_group_id          = "valkey-not-encrypted"
    engine                        = "valkey"
    at_rest_encryption_enabled    = false
  }
}

# Test 8: FAIL - Missing engine (defaults to redis) with missing encryption
resource "aws_elasticache_replication_group" "fail_default_engine_missing_encryption" {
  expect_failure = true
  attrs = {
    replication_group_id          = "default-engine-missing-encryption"
  }
}

# Test 9: PASS - Valkey with encryption and additional attributes
resource "aws_elasticache_replication_group" "pass_valkey_encrypted_full_config" {
  attrs = {
    replication_group_id          = "valkey-encrypted-full"
    engine                        = "valkey"
    engine_version                = "7.2"
    node_type                     = "cache.m6g.large"
    num_cache_clusters            = 3
    at_rest_encryption_enabled    = true
    transit_encryption_enabled    = true
  }
}
