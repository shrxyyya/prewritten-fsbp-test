# Copyright IBM Corp. 2026

# Application and Network Load Balancer target groups should use encrypted health check protocols

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elbv2-targetgroup-healthcheck-protocol-encrypted-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_lb_target_group" "encrypted_health_check" {
    enforcement_level = input.elbv2-targetgroup-healthcheck-protocol-encrypted-enforcement-level
    filter = attrs.target_type != "lambda"

    locals {
        health_check = core::try(attrs.health_check, [])
        has_health_check = core::length(local.health_check) > 0
        health_check_protocol = core::try(local.health_check[0].protocol, "")
    }

    enforce {
        condition = local.has_health_check && local.health_check_protocol == "HTTPS"
        error_message = "Target group does not use HTTPS for health checks. Set health_check.protocol = 'HTTPS' to ensure encrypted communication between the load balancer and targets"
    }
}
