# Copyright IBM Corp. 2026

# CloudTrail trails should be integrated with Amazon CloudWatch Logs

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cloud-trail-cloud-watch-logs-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cloudtrail" "cloud-watch-logs" {
    enforcement_level = input.cloud-trail-cloud-watch-logs-enabled-enforcement-level
    enforce {
        condition = core::try(attrs.cloud_watch_logs_group_arn, "") != ""
        error_message = "CloudTrail trail is not integrated with Amazon CloudWatch Logs"
    }
}
