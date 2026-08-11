# Copyright IBM Corp. 2026

# EKS clusters should run on a supported Kubernetes version

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "eks-cluster-supported-version-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_eks_cluster" "supported_version" {
    enforcement_level = input.eks-cluster-supported-version-enforcement-level
    locals {
        oldest_version_supported = "1.33"
        version = core::try(attrs.version, "1.33")
    }

    enforce {
        condition = local.version == "" || core::semverconstraint(local.version, ">=${local.oldest_version_supported}")
        error_message = "EKS cluster is either missing required 'version' attribute or is running an unsupported Kubernetes version. The cluster must be running a version that is at least '1.33'"
    }
}
