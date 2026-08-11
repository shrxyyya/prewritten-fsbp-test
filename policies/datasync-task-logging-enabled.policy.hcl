# Copyright IBM Corp. 2026

# DataSync tasks should have logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "datasync-task-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_datasync_task" "logging_required" {
  enforcement_level = input.datasync-task-logging-enabled-enforcement-level
  locals {
    # Safe access to cloudwatch_log_group_arn
    log_group_arn = core::try(attrs.cloudwatch_log_group_arn, "")
    has_log_group = local.log_group_arn != ""
    
    # Safe access to options block and log_level
    # options is a list of maps (block), need [0] to access
    options_block = core::try(attrs.options[0], null)
    log_level = core::try(local.options_block.log_level, "OFF")
    
    # Logging is enabled if:
    # 1. CloudWatch log group ARN is configured
    # 2. Log level is not OFF
    logging_enabled = local.has_log_group && local.log_level != "OFF"
  }

  enforce {
    condition = local.has_log_group
    error_message = "DataSync task must have cloudwatch_log_group_arn configured. Configure a CloudWatch Log Group ARN to enable logging"
  }

  enforce {
    condition = local.log_level != "OFF"
    error_message = "DataSync task has logging disabled (log_level = '${local.log_level}'). Set options.log_level to 'BASIC' or 'TRANSFER' to enable logging"
  }
}
