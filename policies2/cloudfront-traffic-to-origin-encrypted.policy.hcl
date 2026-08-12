# Copyright IBM Corp. 2026

# CloudFront distributions should encrypt traffic to custom origins

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cloudfront-traffic-to-origin-encrypted-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cloudfront_distribution" "encrypt_custom_origins" {
  enforcement_level = input.cloudfront-traffic-to-origin-encrypted-enforcement-level
  filter = attrs.origin != null && core::length(attrs.origin) > 0

  locals {
    custom_origins = [
      for origin in attrs.origin : origin
      if core::try(origin.custom_origin_config, null) != null
    ]

    invalid_http_only_origins = [
      for origin in local.custom_origins : core::try(origin.origin_id, "unknown-origin")
      if core::try(origin.custom_origin_config[0].origin_protocol_policy, "") == "http-only"
    ]

    default_viewer_policy = core::try(attrs.default_cache_behavior[0].viewer_protocol_policy, "")

    ordered_viewer_policies = [
      for b in core::try(attrs.ordered_cache_behavior, []) :
      core::try(b.viewer_protocol_policy, "")
    ]

    all_viewer_policies = core::concat([local.default_viewer_policy], local.ordered_viewer_policies)

    # True if any cache behavior (default or ordered) allows unencrypted viewer traffic
    any_behavior_allow_all = core::length([
      for p in local.all_viewer_policies : p if p == "allow-all"
    ]) > 0

    invalid_match_viewer_origins = [
      for origin in local.custom_origins : core::try(origin.origin_id, "unknown-origin")
      if core::try(origin.custom_origin_config[0].origin_protocol_policy, "") == "match-viewer" && local.any_behavior_allow_all
    ]
  }

  enforce {
    condition = core::length(local.invalid_http_only_origins) == 0
    error_message = "CloudFront distribution must not allow custom origins with origin_protocol_policy set to 'http-only'. Violating origins: ${core::join(", ", local.invalid_http_only_origins)}"
  }

  enforce {
    condition = core::length(local.invalid_match_viewer_origins) == 0
    error_message = "CloudFront distribution must not pair a custom origin with origin_protocol_policy 'match-viewer' with any cache behavior (default or ordered) whose viewer_protocol_policy is 'allow-all'. Violating origins: ${core::join(", ", local.invalid_match_viewer_origins)}"
  }
}