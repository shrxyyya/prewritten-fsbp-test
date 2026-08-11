terraform {
  required_version = ">= 1.15.0"

  cloud {

    organization = "nagateja-test-org"

    workspaces {
      name = "provider-test"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_kms_key" "example" {
  description = "EKS secrets encryption key"
}

resource "aws_eks_cluster" "example" {
  name     = "example-eks-cluster"
  role_arn = "arn:aws:iam::123456789012:role/example-eks-cluster-role"
  version  = "1.31"

  enabled_cluster_log_types = ["audit"]

  encryption_config {
    provider {
      key_arn = aws_kms_key.example.arn
    }
    resources = ["secrets"]
  }

  vpc_config {
    endpoint_public_access = false
    subnet_ids             = ["subnet-12345678", "subnet-87654321"]
  }
}

resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = "example-node-group"
  node_role_arn   = "arn:aws:iam::123456789012:role/example-eks-node-role"
  subnet_ids      = ["subnet-12345678", "subnet-87654321"]
  version         = "1.31"

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}
