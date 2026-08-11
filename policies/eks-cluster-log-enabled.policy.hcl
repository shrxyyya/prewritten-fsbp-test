# Copyright IBM Corp. 2026

# EKS clusters should have audit logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "eks-cluster-log-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

input "eks_log_types" {
    type = string
    default = ""
}

resource_policy "aws_eks_cluster" "audit_logging_enabled" {
    enforcement_level = input.eks-cluster-log-enabled-enforcement-level
    locals {
        enabled_log_types = core::try(attrs.enabled_cluster_log_types, [])
        audit_enabled = core::contains(local.enabled_log_types, "audit")
        valid_input = core::contains(core::split(",", input.eks_log_types), "audit")
        input_logs_not_enabled = local.valid_input ? core::contain([
            for type in input.eks_log_types : core::contains(local.enabled_log_types, type)
        ], false) : false
        input_condition = input.eks_log_types != "" ? local.input_logs_not_enabled : true
    }

    enforce {
        condition = local.audit_enabled && local.input_condition
        error_message = "EKS cluster does not have audit logging enabled. Add 'audit' to the 'enabled_cluster_log_types' list to enable audit logging for security and compliance monitoring"
    }
}
