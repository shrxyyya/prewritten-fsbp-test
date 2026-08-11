# Copyright IBM Corp. 2026

policytest {
    targets = [
        "eks-cluster-secrets-encrypted.policy.hcl"
    ]
}

# Test 1: PASS - EKS cluster with proper encryption configuration
resource "aws_eks_cluster" "pass_with_complete_encryption_config" {
  attrs = {
    name = "compliant-cluster"
    role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
    encryption_config = [
      {
        provider = [
          {
            key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
          }
        ]
        resources = ["secrets"]
      }
    ]
    vpc_config = [
      {
        subnet_ids = ["subnet-12345", "subnet-67890"]
      }
    ]
  }
}

# Test 2: FAIL - EKS cluster without encryption_config block
resource "aws_eks_cluster" "fail_without_encryption_config" {
  expect_failure = true
  attrs = {
    name = "no-encryption-cluster"
    role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
    vpc_config = [
      {
        subnet_ids = ["subnet-12345", "subnet-67890"]
      }
    ]
  }
}

# Test 3: FAIL - EKS cluster with encryption_config but no provider.key_arn
resource "aws_eks_cluster" "fail_without_key_arn" {
  expect_failure = true
  attrs = {
    name = "no-key-arn-cluster"
    role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
    encryption_config = [
      {
        provider = []
        resources = ["secrets"]
      }
    ]
    vpc_config = [
      {
        subnet_ids = ["subnet-12345", "subnet-67890"]
      }
    ]
  }
}

# Test 4: FAIL - EKS cluster with encryption_config but secrets not in resources list
resource "aws_eks_cluster" "fail_secrets_not_in_resources" {
  expect_failure = true
  attrs = {
    name = "no-secrets-cluster"
    role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
    encryption_config = [
      {
        provider = [
          {
            key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
          }
        ]
        resources = ["other-resource"]
      }
    ]
    vpc_config = [
      {
        subnet_ids = ["subnet-12345", "subnet-67890"]
      }
    ]
  }
}

# Test 5: FAIL - EKS cluster with encryption_config but empty resources list
resource "aws_eks_cluster" "fail_empty_resources_list" {
  expect_failure = true
  attrs = {
    name = "empty-resources-cluster"
    role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
    encryption_config = [
      {
        provider = [
          {
            key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
          }
        ]
        resources = []
      }
    ]
    vpc_config = [
      {
        subnet_ids = ["subnet-12345", "subnet-67890"]
      }
    ]
  }
}

# Test 6: PASS - EKS cluster with multiple encrypted resources including secrets
resource "aws_eks_cluster" "pass_with_multiple_encrypted_resources" {
  attrs = {
    name = "multiple-resources-cluster"
    role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"
    encryption_config = [
      {
        provider = [
          {
            key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
          }
        ]
        resources = ["secrets", "other-resource"]
      }
    ]
    vpc_config = [
      {
        subnet_ids = ["subnet-12345", "subnet-67890"]
      }
    ]
  }
}
