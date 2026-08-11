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
  type = string
  default = "advisory"
}

resource_policy "aws_eks_cluster" "encrypted_secrets" {
    enforcement_level = input.eks-cluster-secrets-encrypted-enforcement-level
    locals {
        has_encryption_config = core::length(core::try(attrs.encryption_config, [])) > 0
        encryption_config = local.has_encryption_config ? core::try(attrs.encryption_config[0], null) : null
        
        # Check if provider block exists and has key_arn
        has_provider = local.has_encryption_config ? core::try(local.encryption_config.provider, null) != null : false
        has_key_arn = local.has_provider ? core::try(local.encryption_config.provider[0].key_arn, "") != "" : false
        
        encrypted_resources = core::try(local.encryption_config.resources, [])
        secrets_encrypted = core::contains(local.encrypted_resources, "secrets")
    }

    enforce {
        condition = local.has_encryption_config && local.secrets_encrypted
        error_message = "EKS cluster does not encrypt Kubernetes secrets. Add 'secrets' to 'encryption_config.resources' list to enable secrets encryption"
    }

    enforce {
        condition = local.has_key_arn
        error_message = "EKS cluster does not have a KMS key ARN configured for encryption. Set 'encryption_config.provider.key_arn' to enable envelope encryption of Kubernetes secrets"
    }
}
