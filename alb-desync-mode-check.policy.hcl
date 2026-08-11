# Copyright IBM Corp. 2026

# Application Load Balancer should be configured with defensive or strictest desync mitigation mode

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "alb-desync-mode-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_lb" "alb_desync_mitigation_mode" {
    enforcement_level = input.alb-desync-mode-check-enforcement-level
    filter = core::try(attrs.load_balancer_type, "application") == "application"

    locals {
        desync_mode = core::try(attrs.desync_mitigation_mode, "defensive")
        is_valid_mode = core::contains(["defensive", "strictest"], local.desync_mode)
    }

    enforce {
        condition = local.is_valid_mode
        error_message = "Application Load Balancer must be configured with 'defensive' or 'strictest' desync mode to protect against HTTP Desync vulnerabilities"
    }
}
