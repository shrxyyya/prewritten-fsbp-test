# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elasticache-repl-grp-redis-auth-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Redis with transit encryption and auth token, engine version 6.x
resource "aws_elasticache_replication_group" "pass_redis_auth_v6" {
  attrs = {
    replication_group_id          = "redis-auth-v6"
    engine                        = "redis"
    transit_encryption_enabled    = true
    auth_token                    = "my-secure-auth-token-123"
    engine_version                = "6.0"
  }
}

# Test 2: PASS - Redis with transit encryption and auth token, engine version 7.x
resource "aws_elasticache_replication_group" "pass_redis_auth_v7" {
  attrs = {
    replication_group_id          = "redis-auth-v7"
    engine                        = "redis"
    transit_encryption_enabled    = true
    auth_token                    = "another-secure-token-456"
    engine_version                = "7.1"
  }
}

# Test 3: PASS - Redis with transit encryption and auth token, no engine version specified
resource "aws_elasticache_replication_group" "pass_redis_auth_no_version" {
  attrs = {
    replication_group_id          = "redis-auth-no-version"
    engine                        = "redis"
    transit_encryption_enabled    = true
    auth_token                    = "secure-token-789"
  }
}

# Test 4: PASS - Redis with transit encryption and auth token, engine version 6.2.6
resource "aws_elasticache_replication_group" "pass_redis_auth_v6_2_6" {
  attrs = {
    replication_group_id          = "redis-auth-v6-2-6"
    engine                        = "redis"
    transit_encryption_enabled    = true
    auth_token                    = "token-with-specific-version"
    engine_version                = "6.2.6"
  }
}

# Test 5: FAIL - Redis with transit encryption but no auth token, engine version 6.x
resource "aws_elasticache_replication_group" "fail_redis_no_auth_v6" {
  expect_failure = true
  attrs = {
    replication_group_id          = "redis-no-auth-v6"
    engine                        = "redis"
    transit_encryption_enabled    = true
    engine_version                = "6.0"
  }
}

# Test 6: FAIL - Redis with transit encryption but empty auth token, engine version 6.x
resource "aws_elasticache_replication_group" "fail_redis_empty_auth_v6" {
  expect_failure = true
  attrs = {
    replication_group_id          = "redis-empty-auth-v6"
    engine                        = "redis"
    transit_encryption_enabled    = true
    auth_token                    = ""
    engine_version                = "6.0"
  }
}

# Test 7: FAIL - Redis with transit encryption and auth token but engine version 5.x
resource "aws_elasticache_replication_group" "fail_redis_auth_v5" {
  expect_failure = true
  attrs = {
    replication_group_id          = "redis-auth-v5"
    engine                        = "redis"
    transit_encryption_enabled    = true
    auth_token                    = "token-but-old-version"
    engine_version                = "5.0.6"
  }
}

# Test 8: FAIL - Redis with transit encryption and auth token but engine version 4.x
resource "aws_elasticache_replication_group" "fail_redis_auth_v4" {
  expect_failure = true
  attrs = {
    replication_group_id          = "redis-auth-v4"
    engine                        = "redis"
    transit_encryption_enabled    = true
    auth_token                    = "token-but-very-old-version"
    engine_version                = "4.0.10"
  }
}

# Test 9: FAIL - Redis with transit encryption but no auth token and no engine version
resource "aws_elasticache_replication_group" "fail_redis_no_auth_no_version" {
  expect_failure = true
  attrs = {
    replication_group_id          = "redis-no-auth-no-version"
    engine                        = "redis"
    transit_encryption_enabled    = true
  }
}

# Test 10: Skipped - Memcached engine (filtered out by policy)
resource "aws_elasticache_replication_group" "skip_memcached" {
  attrs = {
    replication_group_id          = "memcached-cluster"
    engine                        = "memcached"
    transit_encryption_enabled    = true
    auth_token                    = "token-but-memcached"
    engine_version                = "1.6.6"
  }
}

# Test 11: PASS - Redis with transit encryption and auth token, engine version 7.0.7
resource "aws_elasticache_replication_group" "pass_redis_auth_v7_0_7" {
  attrs = {
    replication_group_id          = "redis-auth-v7-0-7"
    engine                        = "redis"
    transit_encryption_enabled    = true
    auth_token                    = "token-v7-0-7"
    engine_version                = "7.0.7"
  }
}
