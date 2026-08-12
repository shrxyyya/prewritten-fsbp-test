# Copyright IBM Corp. 2026

# DMS endpoints should use SSL

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "dms-endpoint-ssl-configured-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_dms_endpoint" "certificate_arn_required" {
  enforcement_level = input.dms-endpoint-ssl-configured-enforcement-level
  locals {
    certificate_arn     = core::try(attrs.certificate_arn, null)
    has_certificate_arn = local.certificate_arn != null && local.certificate_arn != ""
  }

  enforce {
    condition     = local.has_certificate_arn
    error_message = "Attribute 'certificate_arn' must not be empty for 'aws_dms_endpoint' resources."
  }
}
