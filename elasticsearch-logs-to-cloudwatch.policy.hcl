# Copyright IBM Corp. 2026

# Elasticsearch domain error logging to CloudWatch Logs should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elasticsearch-logs-to-cloudwatch-enforcement-level" {
  type = string
  default = "advisory"
}

input "es_log_types" {
    type = string
    default = "ES_APPLICATION_LOGS"
}

resource_policy "aws_elasticsearch_domain" "error_logging_enabled" {
    enforcement_level = input.elasticsearch-logs-to-cloudwatch-enforcement-level
    filter = core::try(attrs.log_publishing_options, null) != null || core::length(core::try(attrs.log_publishing_options, [])) > 0

    locals {
        inputs = core::split(",", input.es_log_types)
        has_valid_input = core::contains(local.inputs, "ES_APPLICATION_LOGS")
        app_log_configs = [
            for log_config in core::try(attrs.log_publishing_options, []) : log_config
            if log_config.log_type == "ES_APPLICATION_LOGS" || (local.has_valid_input ? core::contains(local.inputs, log_config.log_type) : false)
        ]
        
        has_app_logs = core::length(local.app_log_configs) > 0
        is_enabled = local.has_app_logs ? core::try(local.app_log_configs[0].enabled, true) : false
        
        has_log_group = local.has_app_logs ? core::try(local.app_log_configs[0].cloudwatch_log_group_arn, "") != "" : false
    }

    enforce {
        condition = local.has_app_logs
        error_message = "Elasticsearch domain does not have ES_APPLICATION_LOGS configured. Add log_publishing_options block with log_type = 'ES_APPLICATION_LOGS' to enable error logging"
    }

    enforce {
        condition = local.is_enabled
        error_message = "Elasticsearch domain has ES_APPLICATION_LOGS configured but it is disabled. Set 'enabled = true' or remove the enabled attribute (defaults to true)"
    }

    enforce {
        condition = local.has_log_group
        error_message = "Elasticsearch domain has ES_APPLICATION_LOGS configured but missing cloudwatch_log_group_arn. Specify a valid CloudWatch log group ARN to receive error logs"
    }
}
