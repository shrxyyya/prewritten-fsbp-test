# Copyright IBM Corp. 2026

policytest {
    targets = [
        "docdb-cluster-audit-logging-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Audit logging enabled (only audit)
resource "aws_docdb_cluster" "pass_audit_only" {
  attrs = {
    cluster_identifier                = "docdb-audit-only"
    enabled_cloudwatch_logs_exports   = ["audit"]
    master_username                   = "admin"
    engine                            = "docdb"
  }
}

# Test 2: PASS - Audit logging enabled with profiler
resource "aws_docdb_cluster" "pass_audit_and_profiler" {
  attrs = {
    cluster_identifier                = "docdb-audit-profiler"
    enabled_cloudwatch_logs_exports   = ["audit", "profiler"]
    master_username                   = "admin"
    engine                            = "docdb"
  }
}

# Test 3: PASS - Audit logging enabled (profiler first, then audit)
resource "aws_docdb_cluster" "pass_profiler_then_audit" {
  attrs = {
    cluster_identifier                = "docdb-profiler-audit"
    enabled_cloudwatch_logs_exports   = ["profiler", "audit"]
    master_username                   = "admin"
    engine                            = "docdb"
  }
}

# Test 4: FAIL - Only profiler logging enabled (no audit)
resource "aws_docdb_cluster" "fail_profiler_only" {
  expect_failure = true
  attrs = {
    cluster_identifier                = "docdb-profiler-only"
    enabled_cloudwatch_logs_exports   = ["profiler"]
    master_username                   = "admin"
    engine                            = "docdb"
  }
}

# Test 5: FAIL - Empty CloudWatch logs exports
resource "aws_docdb_cluster" "fail_empty_logs" {
  expect_failure = true
  attrs = {
    cluster_identifier                = "docdb-empty-logs"
    enabled_cloudwatch_logs_exports   = []
    master_username                   = "admin"
    engine                            = "docdb"
  }
}

# Test 6: FAIL - Missing enabled_cloudwatch_logs_exports (defaults to empty list)
resource "aws_docdb_cluster" "fail_missing_logs" {
  expect_failure = true
  attrs = {
    cluster_identifier                = "docdb-missing-logs"
    master_username                   = "admin"
    engine                            = "docdb"
  }
}

# Test 7: FAIL - enabled_cloudwatch_logs_exports explicitly set to null
resource "aws_docdb_cluster" "fail_null_logs" {
  expect_failure = true
  attrs = {
    cluster_identifier                = "docdb-null-logs"
    enabled_cloudwatch_logs_exports   = null
    master_username                   = "admin"
    engine                            = "docdb"
  }
}
