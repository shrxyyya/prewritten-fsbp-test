# Copyright IBM Corp. 2026

policytest {
  targets = ["elasticache-repl-grp-redis-auth-enabled.policy.hcl"]
}

# PASS: engine_version < 6.0 with auth_token set
resource "aws_elasticache_replication_group" "pass_old_version_with_auth_token" {
  attrs = {
    replication_group_id       = "test-rg-pass-1"
    description                = "Test replication group"
    engine_version             = "5.0.6"
    auth_token                 = "mysecrettoken123"
    transit_encryption_enabled = true
  }
}

# PASS: engine_version 4.x < 6.0 with auth_token set
resource "aws_elasticache_replication_group" "pass_version_4_with_auth_token" {
  attrs = {
    replication_group_id       = "test-rg-pass-2"
    description                = "Test replication group"
    engine_version             = "4.0.10"
    auth_token                 = "anothersecrettoken456"
    transit_encryption_enabled = true
  }
}

# PASS: engine_version exactly "6.0" (not < 6.0, auth_token not required)
resource "aws_elasticache_replication_group" "pass_version_exactly_6_0" {
  attrs = {
    replication_group_id = "test-rg-pass-3"
    description          = "Test replication group"
    engine_version       = "6.0"
  }
}

# PASS: engine_version "6.2" >= 6.0, auth_token not required
resource "aws_elasticache_replication_group" "pass_version_6_2" {
  attrs = {
    replication_group_id = "test-rg-pass-4"
    description          = "Test replication group"
    engine_version       = "6.2"
  }
}

# PASS: engine_version "6.x" >= 6.0, auth_token not required
resource "aws_elasticache_replication_group" "pass_version_6_x" {
  attrs = {
    replication_group_id = "test-rg-pass-5"
    description          = "Test replication group"
    engine_version       = "6.x"
  }
}

# PASS: engine_version "7.2" >= 6.0, auth_token not required
resource "aws_elasticache_replication_group" "pass_version_7_2" {
  attrs = {
    replication_group_id = "test-rg-pass-6"
    description          = "Test replication group"
    engine_version       = "7.2"
  }
}

# PASS: engine_version is null — filtered out
resource "aws_elasticache_replication_group" "pass_null_engine_version" {
  attrs = {
    replication_group_id = "test-rg-pass-7"
    description          = "Test replication group"
    engine_version       = null
  }
}

# PASS: engine_version is empty string — filtered out
resource "aws_elasticache_replication_group" "pass_empty_engine_version" {
  attrs = {
    replication_group_id = "test-rg-pass-8"
    description          = "Test replication group"
    engine_version       = ""
  }
}

# FAIL: engine_version < 6.0 and auth_token is null
resource "aws_elasticache_replication_group" "fail_old_version_null_auth_token" {
  expect_failure = true
  attrs = {
    replication_group_id = "test-rg-fail-1"
    description          = "Test replication group"
    engine_version       = "5.0.6"
    auth_token           = null
  }
}

# FAIL: engine_version < 6.0 and auth_token is empty string
resource "aws_elasticache_replication_group" "fail_old_version_empty_auth_token" {
  expect_failure = true
  attrs = {
    replication_group_id = "test-rg-fail-2"
    description          = "Test replication group"
    engine_version       = "5.0.6"
    auth_token           = ""
  }
}

# FAIL: engine_version < 6.0 and auth_token attribute is missing
resource "aws_elasticache_replication_group" "fail_old_version_missing_auth_token" {
  expect_failure = true
  attrs = {
    replication_group_id = "test-rg-fail-3"
    description          = "Test replication group"
    engine_version       = "4.0.10"
  }
}
