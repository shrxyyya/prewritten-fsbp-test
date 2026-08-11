# Copyright IBM Corp. 2026

# AWS AppSync should have field-level logging enabled
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "appsync-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

input "fieldLoggingLevel" {
    type = string
    default = ""
}


resource_policy "aws_appsync_graphql_api" "field_logging_enabled" {
    enforcement_level = input.appsync-logging-enabled-enforcement-level
    locals {
        # Collapse missing or unknown plan values to definite booleans for enforcement.
        raw_log_config = core::try(attrs.log_config, null)
        has_log_config = core::try(core::length(local.raw_log_config) > 0, false)
        log_config = local.has_log_config ? core::try(local.raw_log_config[0], null) : null
        
        # Extract field log level with safe fallback
        field_log_level = core::try(local.log_config.field_log_level, "NONE")
        cloudwatch_logs_role_arn = core::try(local.log_config.cloudwatch_logs_role_arn, "")
        has_cloudwatch_logs_role_arn = core::try(local.cloudwatch_logs_role_arn != "", false)
        
        valid_input_levels = ["ERROR", "ALL"]
        required_log_level = input.fieldLoggingLevel != "" ? input.fieldLoggingLevel : "ERROR"
        has_valid_input_level = core::contains(local.valid_input_levels, local.required_log_level)
        
        # Check if the configured level meets the required minimum.
        has_valid_log_level = core::try((
            (local.required_log_level == "ERROR" && core::contains(["ERROR", "ALL"], local.field_log_level)) ||
            (local.required_log_level == "ALL" && local.field_log_level == "ALL")
        ), false)
        
    }

    enforce {
        condition = local.has_valid_input_level
        error_message = "input.fieldLoggingLevel must be one of ERROR or ALL. Current value: '${input.fieldLoggingLevel}'. Leave it empty to use the default minimum of 'ERROR'."
    }

    enforce {
        condition = local.has_log_config
        error_message = "AppSync API does not have log_config defined. Field-level logging must be enabled with field_log_level set to at least the required minimum from input.fieldLoggingLevel (default 'ERROR') and a valid cloudwatch_logs_role_arn to meet AWS Security Hub AppSync.2 requirements"
    }

    enforce {
        condition = !local.has_log_config || local.has_cloudwatch_logs_role_arn
        error_message = "AppSync API log_config must set a non-empty cloudwatch_logs_role_arn when field-level logging is enabled"
    }

    # Enforce: Field log level must be ERROR or ALL
    enforce {
        condition = !local.has_log_config || local.has_valid_log_level
        error_message = "AppSync API field_log_level '${local.field_log_level}' does not satisfy the required minimum from input.fieldLoggingLevel='${local.required_log_level}'. Set log_config.field_log_level to '${local.required_log_level}' or a more verbose level"
    }

}
