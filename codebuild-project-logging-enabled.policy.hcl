# Copyright IBM Corp. 2026

# CodeBuild project environments should have a logging AWS Configuration
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "codebuild-project-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_codebuild_project" "logging_configuration" {
    enforcement_level = input.codebuild-project-logging-enabled-enforcement-level
    locals {
        # Safe access to logs_config block
        logs_config = core::try(attrs.logs_config, null)
        
        # Check CloudWatch Logs status
        # Default is ENABLED if not specified or if logs_config is absent
        cloudwatch_logs = core::try(local.logs_config[0].cloudwatch_logs, null)
        cloudwatch_status = core::try(local.cloudwatch_logs[0].status, "ENABLED")
        cloudwatch_enabled = local.cloudwatch_status != "DISABLED"
        
        # Check S3 Logs status
        # Default is DISABLED if not specified
        s3_logs = core::try(local.logs_config[0].s3_logs, null)
        s3_status = core::try(local.s3_logs[0].status, "DISABLED")
        s3_enabled = local.s3_status == "ENABLED"
        
        # At least one logging option must be enabled
        has_logging = local.cloudwatch_enabled || local.s3_enabled
    }

    enforce {
        condition = local.has_logging
        error_message = "CodeBuild project must have at least one logging option enabled (CloudWatch Logs or S3 Logs). Current status - CloudWatch: ${local.cloudwatch_status}, S3: ${local.s3_status}"
    }
}