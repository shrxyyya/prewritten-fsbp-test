# Copyright IBM Corp. 2026

# Amazon Connect instances should have CloudWatch logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "connect-instance-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_connect_instance" "cloudwatch_logging_enabled" {
    enforcement_level = input.connect-instance-logging-enabled-enforcement-level
    locals {
        # Safely access the contact_flow_logs_enabled attribute with default false
        contact_flow_logs_enabled = core::try(attrs.contact_flow_logs_enabled, false)
    }

    enforce {
        condition     = local.contact_flow_logs_enabled == true
        error_message = "Amazon Connect instance must have contact flow logs enabled. Set 'contact_flow_logs_enabled = true' to enable CloudWatch logging for contact flows"
    }
}
