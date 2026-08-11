# Copyright IBM Corp. 2026

# CloudTrail log file validation should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cloud-trail-log-file-validation-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cloudtrail" "log-file-validation" {
    enforcement_level = input.cloud-trail-log-file-validation-enabled-enforcement-level
    enforce {
        condition = core::try(attrs.enable_log_file_validation, false)
        error_message = "CloudTrail log file validation is not enabled"
    }
}
