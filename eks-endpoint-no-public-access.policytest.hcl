# Copyright IBM Corp. 2026

policytest {
    targets = [
        "eks-endpoint-no-public-access.policy.hcl"
    ]
}

# Test 1: PASS - EKS cluster with endpoint_public_access explicitly set to false
resource "aws_eks_cluster" "pass_public_access_disabled" {
  attrs = {
    name     = "compliant-cluster"
    role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
    vpc_config = [
      {
        subnet_ids              = ["subnet-12345", "subnet-67890"]
        endpoint_public_access  = false
        endpoint_private_access = true
      }
    ]
  }
}

# Test 2: FAIL - EKS cluster with endpoint_public_access set to true
resource "aws_eks_cluster" "fail_public_access_enabled" {
  expect_failure = true
  attrs = {
    name     = "non-compliant-cluster"
    role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
    vpc_config = [
      {
        subnet_ids              = ["subnet-12345", "subnet-67890"]
        endpoint_public_access  = true
        endpoint_private_access = false
      }
    ]
  }
}

# Test 3: FAIL - EKS cluster with vpc_config but endpoint_public_access not specified (defaults to true)
resource "aws_eks_cluster" "fail_public_access_default" {
  expect_failure = true
  attrs = {
    name     = "default-public-cluster"
    role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
    vpc_config = [
      {
        subnet_ids = ["subnet-12345", "subnet-67890"]
      }
    ]
  }
}

# Test 4: FAIL - EKS cluster without vpc_config block
resource "aws_eks_cluster" "fail_missing_vpc_config" {
  expect_failure = true
  attrs = {
    name     = "no-vpc-config-cluster"
    role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
  }
}

# Test 5: FAIL - EKS cluster with empty vpc_config list
resource "aws_eks_cluster" "fail_empty_vpc_config" {
  expect_failure = true
  attrs = {
    name       = "empty-vpc-config-cluster"
    role_arn   = "arn:aws:iam::123456789012:role/eks-cluster-role"
    vpc_config = []
  }
}
