# Copyright IBM Corp. 2026

# API Gateway REST API stages should have AWS X-Ray tracing enabled
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "api-gw-xray-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_api_gateway_stage" "xray_tracing_required" {
    enforcement_level = input.api-gw-xray-enabled-enforcement-level
    locals {
        # Safe access to xray_tracing_enabled attribute with default false
        xray_enabled = core::try(attrs.xray_tracing_enabled, false)
    }

    enforce {
        condition     = local.xray_enabled == true
        error_message = "API Gateway stage must have X-Ray tracing enabled. Set 'xray_tracing_enabled = true' to enable active tracing for performance monitoring and rapid response to infrastructure changes"
    }
}
