# Copyright IBM Corp. 2026

policytest {
  targets = [
    "docdb-cluster-encrypted-in-transit.policy.hcl"
  ]
}
# PASS: TLS set to tls1.2+ (secure)
resource "aws_docdb_cluster" "pass_tls_1_2_plus" {
  attrs = {
    cluster_identifier = "secure-docdb-cluster"
    db_cluster_parameter_group_name = "secure-param-group"
    engine = "docdb"
  }
}

resource "aws_docdb_cluster_parameter_group" "secure_param_group" {
  attrs = {
    name = "secure-param-group"
    family = "docdb5.0"
    parameter = [
      {
        name = "tls"
        value = "tls1.2+"
        apply_method = "immediate"
      }
    ]
  }
}

# PASS: TLS set to tls1.3+ (secure)
resource "aws_docdb_cluster" "pass_tls_1_3_plus" {
  attrs = {
    cluster_identifier = "secure-docdb-cluster-v13"
    db_cluster_parameter_group_name = "secure-param-group-v13"
    engine = "docdb"
  }
}

resource "aws_docdb_cluster_parameter_group" "secure_param_group_v13" {
  attrs = {
    name = "secure-param-group-v13"
    family = "docdb5.0"
    parameter = [
      {
        name = "tls"
        value = "tls1.3+"
        apply_method = "immediate"
      }
    ]
  }
}

# PASS: TLS set to fips-140-3 (secure)
resource "aws_docdb_cluster" "pass_fips_140_3" {
  attrs = {
    cluster_identifier = "fips-docdb-cluster"
    db_cluster_parameter_group_name = "fips-param-group"
    engine = "docdb"
  }
}

resource "aws_docdb_cluster_parameter_group" "fips_param_group" {
  attrs = {
    name = "fips-param-group"
    family = "docdb5.0"
    parameter = [
      {
        name = "tls"
        value = "fips-140-3"
        apply_method = "immediate"
      }
    ]
  }
}

# FAIL: TLS set to disabled (insecure)
resource "aws_docdb_cluster" "fail_tls_disabled" {
  expect_failure = true
  attrs = {
    cluster_identifier = "insecure-docdb-cluster"
    db_cluster_parameter_group_name = "insecure-param-group"
    engine = "docdb"
  }
}

resource "aws_docdb_cluster_parameter_group" "insecure_param_group" {
  attrs = {
    name = "insecure-param-group"
    family = "docdb5.0"
    parameter = [
      {
        name = "tls"
        value = "disabled"
        apply_method = "immediate"
      }
    ]
  }
}

# FAIL: TLS set to enabled (insecure - allows non-TLS)
resource "aws_docdb_cluster" "fail_tls_enabled" {
  expect_failure = true
  attrs = {
    cluster_identifier = "weak-docdb-cluster"
    db_cluster_parameter_group_name = "weak-param-group"
    engine = "docdb"
  }
}

resource "aws_docdb_cluster_parameter_group" "weak_param_group" {
  attrs = {
    name = "weak-param-group"
    family = "docdb5.0"
    parameter = [
      {
        name = "tls"
        value = "enabled"
        apply_method = "immediate"
      }
    ]
  }
}

# FAIL: TLS parameter not set
resource "aws_docdb_cluster" "fail_tls_not_set" {
  expect_failure = true
  attrs = {
    cluster_identifier = "unset-docdb-cluster"
    db_cluster_parameter_group_name = "unset-param-group"
    engine = "docdb"
  }
}

resource "aws_docdb_cluster_parameter_group" "unset_param_group" {
  attrs = {
    name = "unset-param-group"
    family = "docdb5.0"
    parameter = [
      {
        name = "audit_logs"
        value = "enabled"
        apply_method = "immediate"
      }
    ]
  }
}

# FAIL: Parameter group does not exist
resource "aws_docdb_cluster" "fail_missing_param_group" {
  expect_failure = true
  attrs = {
    cluster_identifier = "orphan-docdb-cluster"
    db_cluster_parameter_group_name = "nonexistent-param-group"
    engine = "docdb"
  }
}