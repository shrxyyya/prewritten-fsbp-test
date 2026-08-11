# Copyright IBM Corp. 2026

policytest {
    targets = [
        "eks-cluster-log-enabled.policy.hcl"
    ]
}

# Test 1: PASS - EKS cluster with audit logging enabled
resource "aws_eks_cluster" "pass_with_audit_enabled" {
  attrs = {
    name                      = "example-cluster"
    role_arn                  = "arn:aws:iam::123456789012:role/eks-cluster-role"
    enabled_cluster_log_types = ["audit"]
    vpc_config = [{
      subnet_ids = ["subnet-12345", "subnet-67890"]
    }]
  }
}

# Test 2: PASS - EKS cluster with all log types enabled including audit
resource "aws_eks_cluster" "pass_with_all_log_types" {
  attrs = {
    name                      = "full-logging-cluster"
    role_arn                  = "arn:aws:iam::123456789012:role/eks-cluster-role"
    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
    vpc_config = [{
      subnet_ids = ["subnet-12345", "subnet-67890"]
    }]
  }
}

# Test 3: FAIL - EKS cluster without audit logging
resource "aws_eks_cluster" "fail_without_audit" {
  expect_failure = true
  attrs = {
    name                      = "no-audit-cluster"
    role_arn                  = "arn:aws:iam::123456789012:role/eks-cluster-role"
    enabled_cluster_log_types = ["api", "authenticator"]
    vpc_config = [{
      subnet_ids = ["subnet-12345", "subnet-67890"]
    }]
  }
}

# Test 4: FAIL - EKS cluster with empty log types list
resource "aws_eks_cluster" "fail_with_empty_log_types" {
  expect_failure = true
  attrs = {
    name                      = "empty-logs-cluster"
    role_arn                  = "arn:aws:iam::123456789012:role/eks-cluster-role"
    enabled_cluster_log_types = []
    vpc_config = [{
      subnet_ids = ["subnet-12345"]
    }]
  }
}

# Test 5: FAIL - EKS cluster without enabled_cluster_log_types attribute
resource "aws_eks_cluster" "fail_without_log_types_attribute" {
  expect_failure = true
  attrs = {
    name     = "no-log-types-cluster"
    role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
    vpc_config = [{
      subnet_ids = ["subnet-12345", "subnet-67890"]
    }]
  }
}
