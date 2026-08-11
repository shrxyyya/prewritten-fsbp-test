# Copyright IBM Corp. 2026

# CloudFront distributions should use trusted key groups for signed URLs and cookies

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cloudfront-distribution-key-group-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cloudfront_distribution" "trusted_key_groups_required" {
    enforcement_level = input.cloudfront-distribution-key-group-enabled-enforcement-level
    locals {
        # Check default_cache_behavior for trusted_signers (deprecated)
        default_has_trusted_signers = core::try(
            attrs.default_cache_behavior[0].trusted_signers != null &&
            core::length(attrs.default_cache_behavior[0].trusted_signers) > 0,
            false
        )

        # Check default_cache_behavior for trusted_key_groups (recommended)
        default_has_trusted_key_groups = core::try(
            attrs.default_cache_behavior[0].trusted_key_groups != null &&
            core::length(attrs.default_cache_behavior[0].trusted_key_groups) > 0,
            false
        )

        # Check ordered_cache_behavior for trusted_signers (deprecated)
        ordered_cache_behaviors = core::try(attrs.ordered_cache_behavior, [])
        ordered_with_trusted_signers = [
            for behavior in local.ordered_cache_behaviors :
            behavior if core::try(behavior.trusted_signers != null && core::length(behavior.trusted_signers) > 0, false)
        ]

        ordered_with_trusted_key_groups = [
            for behavior in local.ordered_cache_behaviors :
            behavior if core::try(behavior.trusted_key_groups != null && core::length(behavior.trusted_key_groups) > 0, false)
        ]

        # True if any cache behavior (default or ordered) configures authentication
        uses_authentication = local.default_has_trusted_signers || local.default_has_trusted_key_groups || core::length(local.ordered_with_trusted_signers) > 0 || core::length(local.ordered_with_trusted_key_groups) > 0

        # True if the deprecated trusted_signers field is used anywhere
        uses_trusted_signers = local.default_has_trusted_signers || core::length(local.ordered_with_trusted_signers) > 0

        # True if at least one cache behavior uses the recommended trusted_key_groups
        uses_trusted_key_groups = local.default_has_trusted_key_groups || core::length(local.ordered_with_trusted_key_groups) > 0
    }

    # Rule A: the deprecated trusted_signers attribute must not be used anywhere.
    enforce {
        condition     = !local.uses_trusted_signers
        error_message = "CloudFront distribution uses the deprecated 'trusted_signers' attribute on one or more cache behaviors. Migrate to 'trusted_key_groups' for signed URLs/cookies"
    }

    # Rule B: if any cache behavior configures authentication, it must use trusted_key_groups.
    enforce {
        condition     = !local.uses_authentication || local.uses_trusted_key_groups
        error_message = "CloudFront distribution configures signed-URL/cookie authentication but does not use 'trusted_key_groups' on any cache behavior. Configure trusted_key_groups on the relevant default/ordered cache behaviors"
    }
}
