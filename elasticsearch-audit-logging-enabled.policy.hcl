# Copyright IBM Corp. 2026

# Elasticsearch domains should have audit logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elasticsearch-audit-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

input "cloudwatch_log_group_arn_list" {
    type = string
    default = ""
}

resource_policy "aws_elasticsearch_domain" "audit_logging_enabled" {
    enforcement_level = input.elasticsearch-audit-logging-enabled-enforcement-level
    filter = attrs.log_publishing_options != null && core::length(attrs.log_publishing_options) > 0

    locals {
        inputs = input.cloudwatch_log_group_arn_list != "" ? core::split(",", input.cloudwatch_log_group_arn_list) : []

        audit_log_configs = [
            for config in core::try(attrs.log_publishing_options, []) : config
            if config.log_type == "AUDIT_LOGS" && core::try(config.cloudwatch_log_group_arn, "") != ""  && (
                core::length(local.inputs) > 0 ? core::contains(local.inputs, core::try(config.cloudwatch_log_group_arn, "")) : true
            )
        ]
        has_audit_logs = core::length(local.audit_log_configs) > 0
        audit_enabled = local.has_audit_logs ? core::try(local.audit_log_configs[0].enabled, true) : false
    }

    enforce {
        condition = local.has_audit_logs
        error_message = "Elasticsearch domain does not have audit logging configured. Add a log_publishing_options block with log_type = 'AUDIT_LOGS' and a valid cloudwatch_log_group_arn to enable audit logging"
    }

    enforce {
        condition = local.audit_enabled
        error_message = "Elasticsearch domain has audit logging disabled. Set 'enabled = true' in the AUDIT_LOGS log_publishing_options block"
    }
}
