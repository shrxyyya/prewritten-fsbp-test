# Copyright IBM Corp. 2026

# EKS clusters should use encrypted Kubernetes secrets

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "eks-cluster-secrets-encrypted-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_eks_cluster" "eks_cluster_encrypted_kubernetes_secrets" {
  enforcement_level = input.eks-cluster-secrets-encrypted-enforcement-level

  locals {
    encryption_config = core::try(attrs.encryption_config, [])
    has_encryption    = core::length(local.encryption_config) > 0
    provider_config   = core::try(local.encryption_config[0].provider, [])
    has_provider      = local.has_encryption && core::length(local.provider_config) > 0
    key_arn           = core::try(local.provider_config[0].key_arn, "")
    has_key_arn       = local.has_provider && local.key_arn != "" && local.key_arn != null
    resources         = core::try(local.encryption_config[0].resources, [])
    has_secrets       = local.has_encryption && core::contains(local.resources, "secrets")
    is_compliant      = local.has_encryption && local.has_provider && local.has_key_arn && local.has_secrets
  }

  enforce {
    condition     = local.is_compliant
    error_message = "Invalid 'encryption_config' attribute present for 'aws_eks_cluster' resources."
  }
}
