# Copyright IBM Corp. 2026

# Athena workgroups should have logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "athena-workgroup-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_athena_workgroup" "logging-enabled" {
    enforcement_level = input.athena-workgroup-logging-enabled-enforcement-level
    enforce {
        condition = core::try(attrs.configuration[0].publish_cloudwatch_metrics_enabled, true)
        error_message = "Athena workgroup does not have logging enabled"
    }
}
