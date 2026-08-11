# Copyright IBM Corp. 2026

# Elastic Beanstalk should stream logs to CloudWatch

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elastic-beanstalk-logs-to-cloudwatch-enforcement-level" {
  type = string
  default = "advisory"
}

input "RetentionInDays" {
  type = string
  default = ""
}

resource_policy "aws_elastic_beanstalk_environment" "logs_to_cloudwatch" {
  enforcement_level = input.elastic-beanstalk-logs-to-cloudwatch-enforcement-level
  locals {

    # Extract all settings from the environment
    settings = core::try(attrs.setting, [])
    env_name = core::try(attrs.name, "Elastic Beanstalk environment")
    
    # Check for CloudWatch Logs streaming configuration
    # The namespace for CloudWatch Logs is "aws:elasticbeanstalk:cloudwatch:logs"
    cloudwatch_log_settings = [
      for setting in local.settings :
      setting if setting.namespace == "aws:elasticbeanstalk:cloudwatch:logs"
    ]
    
    # Check if StreamLogs is enabled
    stream_logs_settings = [
      for setting in local.cloudwatch_log_settings :
      setting if setting.name == "StreamLogs" && setting.value == "true"
    ]
    
    # Check if logs are being streamed
    logs_enabled = core::length(local.stream_logs_settings) > 0
    
    # Optional: Check retention period if specified
    retention_settings = [
      for setting in local.cloudwatch_log_settings :
      setting if setting.name == "RetentionInDays"
    ]
    
    has_retention = core::length(local.retention_settings) > 0
    retention_value = local.has_retention ? local.retention_settings[0].value : ""
    
    # Valid retention values per AWS Security Hub specification
    valid_retention_values = ["1", "3", "5", "7", "14", "30", "60", "90", "120", "150", "180", "365", "400", "545", "731", "1827", "3653"]
    
    # Check if retention is valid (if specified)
    retention_valid = !local.has_retention || core::contains(local.valid_retention_values, local.retention_value)
    retention_input_configured = input.RetentionInDays != ""
    retention_input_allowed = !local.retention_input_configured || core::contains(local.valid_retention_values, input.RetentionInDays)
    retention_matches_input = !local.retention_input_configured || local.retention_value == input.RetentionInDays
  }

  enforce {
    condition = local.logs_enabled
    error_message = "Elastic Beanstalk environment '${local.env_name}' must be configured to stream logs to CloudWatch Logs. Configure the 'aws:elasticbeanstalk:cloudwatch:logs' namespace with 'StreamLogs' set to 'true'"
  }

  enforce {
    condition = local.retention_valid
    error_message = "Elastic Beanstalk environment '${local.env_name}' has invalid RetentionInDays value '${local.retention_value}'. Valid values are: ${core::join(", ", local.valid_retention_values)}"
  }

  enforce {
    condition = local.retention_input_allowed
    error_message = "Elastic Beanstalk logs input RetentionInDays must be one of: ${core::join(", ", local.valid_retention_values)} when configured. Current input value: '${input.RetentionInDays}'."
  }

  enforce {
    condition = local.retention_matches_input
    error_message = "Elastic Beanstalk environment '${local.env_name}' must set RetentionInDays = '${input.RetentionInDays}' in the 'aws:elasticbeanstalk:cloudwatch:logs' namespace when the input is configured. Current value: '${local.retention_value}'"
  }
}
