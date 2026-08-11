# Copyright IBM Corp. 2026

# CodeBuild S3 logs should be encrypted

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "codebuild-project-s3-logs-encrypted-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_codebuild_project" "s3_logs_encrypted" {
    enforcement_level = input.codebuild-project-s3-logs-encrypted-enforcement-level
    locals {
        # Safe access to logs_config block (it's a block, so needs [0] if present)
        logs_config = core::try(attrs.logs_config[0], null)
        
        # Safe access to s3_logs block within logs_config
        s3_logs = core::try(local.logs_config.s3_logs[0], null)
        
        # Check if S3 logging is enabled
        s3_logging_enabled = local.s3_logs != null && core::try(local.s3_logs.status, "DISABLED") == "ENABLED"
        
        # Check if encryption is explicitly disabled (default is false, meaning encryption is ON)
        encryption_disabled = core::try(local.s3_logs.encryption_disabled, false)
        
        # Policy passes if:
        # 1. S3 logging is not enabled, OR
        # 2. S3 logging is enabled AND encryption is not disabled
        is_compliant = !local.s3_logging_enabled || (local.s3_logging_enabled && !local.encryption_disabled)
    }

    enforce {
        condition = local.is_compliant
        error_message = "CodeBuild project has S3 logging enabled but encryption is disabled. Set 'encryption_disabled = false' or remove the attribute to enable encryption (default behavior)"
    }
}