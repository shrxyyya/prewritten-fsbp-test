# Copyright IBM Corp. 2026

policytest {
  targets = ["eks-cluster-secrets-encrypted.policy.hcl"]
}

# PASS: Fully compliant cluster with valid KMS key_arn and resources containing "secrets"
resource "aws_eks_cluster" "pass_fully_compliant" {
  attrs = {
    name     = "test-cluster-pass"
    role_arn = "arn:aws:iam::123456789012:role/eks-role"
    vpc_config = [{
      subnet_ids = ["subnet-12345678", "subnet-87654321"]
    }]
    encryption_config = [{
      provider = [{
        key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
      }]
      resources = ["secrets"]
    }]
  }
}

# FAIL: No encryption_config block at all
resource "aws_eks_cluster" "fail_missing_encryption_config" {
  expect_failure = true
  attrs = {
    name     = "test-cluster-no-encryption"
    role_arn = "arn:aws:iam::123456789012:role/eks-role"
    vpc_config = [{
      subnet_ids = ["subnet-12345678", "subnet-87654321"]
    }]
  }
}

# FAIL: Empty encryption_config list
resource "aws_eks_cluster" "fail_empty_encryption_config" {
  expect_failure = true
  attrs = {
    name     = "test-cluster-empty-encryption"
    role_arn = "arn:aws:iam::123456789012:role/eks-role"
    vpc_config = [{
      subnet_ids = ["subnet-12345678", "subnet-87654321"]
    }]
    encryption_config = []
  }
}

# FAIL: encryption_config present but provider block is missing
resource "aws_eks_cluster" "fail_missing_provider" {
  expect_failure = true
  attrs = {
    name     = "test-cluster-no-provider"
    role_arn = "arn:aws:iam::123456789012:role/eks-role"
    vpc_config = [{
      subnet_ids = ["subnet-12345678", "subnet-87654321"]
    }]
    encryption_config = [{
      provider  = []
      resources = ["secrets"]
    }]
  }
}

# FAIL: provider present but key_arn is empty string
resource "aws_eks_cluster" "fail_empty_key_arn" {
  expect_failure = true
  attrs = {
    name     = "test-cluster-empty-key-arn"
    role_arn = "arn:aws:iam::123456789012:role/eks-role"
    vpc_config = [{
      subnet_ids = ["subnet-12345678", "subnet-87654321"]
    }]
    encryption_config = [{
      provider = [{
        key_arn = ""
      }]
      resources = ["secrets"]
    }]
  }
}

# FAIL: provider present but key_arn is null
resource "aws_eks_cluster" "fail_null_key_arn" {
  expect_failure = true
  attrs = {
    name     = "test-cluster-null-key-arn"
    role_arn = "arn:aws:iam::123456789012:role/eks-role"
    vpc_config = [{
      subnet_ids = ["subnet-12345678", "subnet-87654321"]
    }]
    encryption_config = [{
      provider = [{
        key_arn = null
      }]
      resources = ["secrets"]
    }]
  }
}

# FAIL: valid key_arn but resources list does not contain "secrets"
resource "aws_eks_cluster" "fail_resources_no_secrets" {
  expect_failure = true
  attrs = {
    name     = "test-cluster-no-secrets-resource"
    role_arn = "arn:aws:iam::123456789012:role/eks-role"
    vpc_config = [{
      subnet_ids = ["subnet-12345678", "subnet-87654321"]
    }]
    encryption_config = [{
      provider = [{
        key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
      }]
      resources = ["configmaps"]
    }]
  }
}

# FAIL: resources list is empty
resource "aws_eks_cluster" "fail_empty_resources" {
  expect_failure = true
  attrs = {
    name     = "test-cluster-empty-resources"
    role_arn = "arn:aws:iam::123456789012:role/eks-role"
    vpc_config = [{
      subnet_ids = ["subnet-12345678", "subnet-87654321"]
    }]
    encryption_config = [{
      provider = [{
        key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
      }]
      resources = []
    }]
  }
}

# PASS: resources list contains "secrets" along with other values
resource "aws_eks_cluster" "pass_resources_includes_secrets" {
  attrs = {
    name     = "test-cluster-multi-resources"
    role_arn = "arn:aws:iam::123456789012:role/eks-role"
    vpc_config = [{
      subnet_ids = ["subnet-12345678", "subnet-87654321"]
    }]
    encryption_config = [{
      provider = [{
        key_arn = "arn:aws:kms:us-east-1:123456789012:key/abcdef12-abcd-abcd-abcd-abcdef123456"
      }]
      resources = ["secrets", "configmaps"]
    }]
  }
}
