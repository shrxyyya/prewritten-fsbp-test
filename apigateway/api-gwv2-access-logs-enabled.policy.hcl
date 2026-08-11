# Copyright IBM Corp. 2026

# Access logging should be configured for API Gateway V2 Stages

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "api-gwv2-access-logs-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_apigatewayv2_stage" "access_logging_required" {
    enforcement_level = input.api-gwv2-access-logs-enabled-enforcement-level
    # Description: Ensures API Gateway V2 stages have access logging configured
    # with both destination_arn and format specified

    locals {
        # Safe access to access_log_settings block
        access_log_settings = core::try(attrs.access_log_settings, [])
        
        # Check if access_log_settings exists and is not empty
        has_access_log_settings = core::length(local.access_log_settings) > 0
        
        # Extract destination_arn and format if settings exist
        destination_arn = local.has_access_log_settings ? core::try(local.access_log_settings[0].destination_arn, "") : ""
        
        log_format = local.has_access_log_settings ? core::try(local.access_log_settings[0].format, "") : ""
        
        # Validation checks
        has_destination = local.destination_arn != "" && local.destination_arn != null
        has_format = local.log_format != "" && local.log_format != null
    }

    # Enforce: access_log_settings must be configured
    enforce {
        condition = local.has_access_log_settings
        error_message = "API Gateway V2 stage must have access_log_settings configured. Access logs provide detailed information about API access patterns and are required for security audits and forensics investigation"
    }

    # Enforce: destination_arn must be specified
    enforce {
        condition = local.has_destination
        error_message = "API Gateway V2 stage must have destination_arn specified in access_log_settings. The destination_arn should reference a valid CloudWatch Logs log group ARN"
    }

    # Enforce: format must be specified
    enforce {
        condition = local.has_format
        error_message = "API Gateway V2 stage must have format specified in access_log_settings. The format defines the log format specification for access logs"
    }
}
