# Copyright IBM Corp. 2026

# EC2 VPN connections should have logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.30.0, < 7.0.0"
    }
  }
}

input "ec2-vpn-connection-logging-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_vpn_connection" "vpn_connection_logging_enabled" {
    enforcement_level = input.ec2-vpn-connection-logging-enabled-enforcement-level
    locals {
        tunnel1_log_enabled = core::try(attrs.tunnel1_log_options[0].cloudwatch_log_options[0].log_enabled, false)
        tunnel2_log_enabled = core::try(attrs.tunnel2_log_options[0].cloudwatch_log_options[0].log_enabled, false)
        tunnel1_log_group_configured = core::try(attrs.tunnel1_log_options[0].cloudwatch_log_options[0].log_group_arn, "") != ""
        tunnel2_log_group_configured = core::try(attrs.tunnel2_log_options[0].cloudwatch_log_options[0].log_group_arn, "") != ""
    }

    enforce {
        condition = local.tunnel1_log_enabled == true && local.tunnel2_log_enabled == true
        error_message = "AWS Site-to-Site VPN connection must enable CloudWatch Logs for both tunnels by setting both tunnel1_log_options.cloudwatch_log_options.log_enabled and tunnel2_log_options.cloudwatch_log_options.log_enabled to true"
    }

    enforce {
        condition = local.tunnel1_log_group_configured == true && local.tunnel2_log_group_configured == true
        error_message = "AWS Site-to-Site VPN connection must configure a non-empty CloudWatch Log Group ARN for both tunnels in tunnel1_log_options.cloudwatch_log_options.log_group_arn and tunnel2_log_options.cloudwatch_log_options.log_group_arn"
    }
}
