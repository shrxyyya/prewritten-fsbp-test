# Copyright IBM Corp. 2026

# CodeBuild report group exports should be encrypted at rest

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "codebuild-report-group-encrypted-at-rest-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_codebuild_report_group" "encryption_required" {
    enforcement_level = input.codebuild-report-group-encrypted-at-rest-enforcement-level
    # Filter to only report groups that export to S3
    filter = attrs.export_config != null && core::length(attrs.export_config) > 0 && core::try(attrs.export_config[0].type, "") == "S3"

    locals {
        # Extract export configuration
        export_config = core::try(attrs.export_config[0], null)
        s3_destination = core::try(local.export_config.s3_destination, null)
        
        # Check encryption settings
        has_s3_destination = local.s3_destination != null && core::length(local.s3_destination) > 0
        encryption_key = core::try(local.s3_destination[0].encryption_key, "")
        encryption_disabled = core::try(local.s3_destination[0].encryption_disabled, false)
        
        # Validation checks
        has_encryption_key = local.encryption_key != ""
        is_encryption_enabled = !local.encryption_disabled
    }

    # Enforce: S3 destination must be configured
    enforce {
        condition = local.has_s3_destination
        error_message = "CodeBuild report group exports to S3 but s3_destination is not properly configured"
    }

    # Enforce: Encryption must not be explicitly disabled
    enforce {
        condition = local.is_encryption_enabled
        error_message = "CodeBuild report group has encryption explicitly disabled (encryption_disabled = true). Encryption must be enabled for S3 exports"
    }

    # Enforce: KMS encryption key must be specified
    enforce {
        condition = local.has_encryption_key
        error_message = "CodeBuild report group is missing encryption_key for S3 export. Specify a KMS key ARN to encrypt report data at rest"
    }
}
