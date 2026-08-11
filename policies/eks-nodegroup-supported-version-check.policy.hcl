# Copyright IBM Corp. 2026

# EKS node groups should run on a supported Kubernetes version

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "eks-nodegroup-supported-version-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_eks_node_group" "supported_ng_version" {
    enforcement_level = input.eks-nodegroup-supported-version-check-enforcement-level
    locals {
        cluster_config = core::getresources("aws_eks_cluster", {
            name = attrs.cluster_name
        })[0]
        version = core::try(local.cluster_config.version, "1.33")
        oldest_ng_version_supported = "1.33"
    }

    enforce {
        condition = local.version == "" || core::semverconstraint(local.version, ">=${local.oldest_ng_version_supported}")
        error_message = "EKS node group is either missing required 'version' attribute or is running an unsupported Kubernetes version. The node group must be running a version that is at least '1.33'"
    }
}
