# Copyright IBM Corp. 2026

# Application Load Balancer should be configured to drop invalid http headers

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "alb-http-drop-invalid-header-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_lb" "drop_invalid_header_fields_enabled" {
    enforcement_level = input.alb-http-drop-invalid-header-enabled-enforcement-level
    filter = core::try(attrs.load_balancer_type, "application") == "application"

    locals {
        drop_invalid_header_fields_enabled = core::try(attrs.drop_invalid_header_fields, false)
    }

    enforce {
        condition = local.drop_invalid_header_fields_enabled == true
        error_message = "Application Load Balancer must set drop_invalid_header_fields = true to drop invalid HTTP headers"
    }
}
