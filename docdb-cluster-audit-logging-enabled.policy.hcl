# Copyright IBM Corp. 2026

# Amazon DocumentDB clusters should publish audit logs to CloudWatch Logs

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "docdb-cluster-audit-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_docdb_cluster" "audit-logging-enabled" {
    enforcement_level = input.docdb-cluster-audit-logging-enabled-enforcement-level
    locals {
        # core::try only catches errors, not explicit nulls.
        # Use a ternary null-guard so core::contains never receives null.
        cloudwatch_logs_exports = core::try(attrs.enabled_cloudwatch_logs_exports, null)
        logs_list = local.cloudwatch_logs_exports != null ? local.cloudwatch_logs_exports : []
        has_audit_logging = core::contains(local.logs_list, "audit")
    }

    enforce {
        condition = local.has_audit_logging
        error_message = "The DocumentDB cluster does not have audit logging enabled"
    }
}