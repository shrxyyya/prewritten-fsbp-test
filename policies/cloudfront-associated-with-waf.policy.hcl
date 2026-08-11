# Copyright IBM Corp. 2026

# CloudFront distributions should have WAF enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cloudfront-associated-with-waf-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cloudfront_distribution" "waf_enabled" {
    enforcement_level = input.cloudfront-associated-with-waf-enforcement-level
    locals {
        # Safely extract web_acl_id attribute.
        # core::try only catches errors, not explicit nulls, so we must also
        # guard against null separately using a ternary check.
        web_acl_id_value = core::try(attrs.web_acl_id, null)

        # Check if web_acl_id is configured, not null, and not empty string
        has_waf = local.web_acl_id_value != null && local.web_acl_id_value != ""
    }

    enforce {
        condition = local.has_waf
        error_message = "CloudFront distribution must be associated with an AWS WAF web ACL. Configure the 'web_acl_id' argument with either a WAFv2 ACL ARN (e.g., aws_wafv2_web_acl.example.arn) or a WAF Classic ACL ID (e.g., aws_waf_web_acl.example.id)"
    }
}
