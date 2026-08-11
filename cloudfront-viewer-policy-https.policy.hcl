# Copyright IBM Corp. 2026

# CloudFront distributions should require encryption in transit

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cloudfront-viewer-policy-https-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cloudfront_distribution" "viewer-policy-https" {
    enforcement_level = input.cloudfront-viewer-policy-https-enforcement-level
    locals {
        default_cache_behavior = core::try(attrs.default_cache_behavior[0].viewer_protocol_policy, "") != "allow-all"
        ordered_cache_behavior = core::try(attrs.ordered_cache_behavior[0].viewer_protocol_policy, "") != "allow-all"
    }
    enforce {
        condition = local.default_cache_behavior && local.ordered_cache_behavior
        error_message = "CloudFront distribution viewer_protocol_policy is set to 'allow-all'"
    }
}
