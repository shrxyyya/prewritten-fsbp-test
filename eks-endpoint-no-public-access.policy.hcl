# Copyright IBM Corp. 2026

# EKS cluster endpoints should not be publicly accessible

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "eks-endpoint-no-public-access-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_eks_cluster" "endpoint_no_public_access" {
    enforcement_level = input.eks-endpoint-no-public-access-enforcement-level
    locals {
        vpc_config = core::try(attrs.vpc_config, []) != [] ? attrs.vpc_config[0] : null
    }

    enforce {
        condition = core::try(attrs.vpc_config, []) != [] && core::try(local.vpc_config.endpoint_public_access, true) == false
        error_message = "EKS cluster is either missing required 'vpc_config' block or has a publicly accessible endpoint. The vpc_config block must be defined with 'endpoint_public_access = false' to ensure the cluster endpoint is not publicly accessible"
    }
}
