# Copyright IBM Corp. 2026

# CloudFront distributions should have origin failover configured

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cloudfront-origin-failover-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cloudfront_distribution" "origin_failover_required" {
    enforcement_level = input.cloudfront-origin-failover-enabled-enforcement-level
    # Only skip distributions explicitly disabled. Treat omitted enabled as true.
    filter = core::try(attrs.enabled, true) == true

    locals {
        # Safe access to origin_group attribute
        origin_groups = core::try(attrs.origin_group, [])
        
        # Check if at least one origin group is configured
        has_origin_group = core::length(local.origin_groups) > 0
        
        # Validate each origin group has required configuration
        valid_origin_groups = [
            for og in local.origin_groups :
            og if (
                # Must have origin_id
                core::try(og.origin_id, "") != "" &&
                # Must have failover_criteria
                core::try(og.failover_criteria, null) != null &&
                # Must have at least 2 members
                core::length(core::try(og.member, [])) >= 2 &&
                # Failover criteria must have status_codes
                core::length(core::try(og.failover_criteria[0].status_codes, [])) > 0
            )
        ]
        
        # Check if all origin groups are valid
        all_groups_valid = core::length(local.valid_origin_groups) == core::length(local.origin_groups) && core::length(local.origin_groups) > 0
        
        # Get all origin_group IDs for cache behavior validation
        origin_group_ids = [
            for og in local.origin_groups :
            core::try(og.origin_id, "")
        ]
        
        # Check default cache behavior references an origin group
        default_cache_target = core::try(attrs.default_cache_behavior[0].target_origin_id, "")
        default_uses_origin_group = core::contains(local.origin_group_ids, local.default_cache_target)
        
        # Get all ordered cache behaviors
        ordered_behaviors = core::try(attrs.ordered_cache_behavior, [])
        
        # Check if any cache behavior references origin groups (for distributions with ordered behaviors)
        has_ordered_behaviors = core::length(local.ordered_behaviors) > 0
        ordered_behavior_targets = [
            for behavior in local.ordered_behaviors :
            core::try(behavior.target_origin_id, "")
        ]
        
        # At least one cache behavior should use origin group if origin groups are configured
        # Check if any ordered behavior targets match origin group IDs
        matching_ordered_targets = [
            for target in local.ordered_behavior_targets :
            target if core::contains(local.origin_group_ids, target)
        ]
        any_behavior_uses_group = local.default_uses_origin_group || core::length(local.matching_ordered_targets) > 0
    }

    # Enforce: Must have at least one origin group
    enforce {
        condition = local.has_origin_group
        error_message = "CloudFront distribution must have at least one origin_group configured for high availability. Origin failover requires configuring an origin group with primary and failover origins"
    }

    # Enforce: All origin groups must be properly configured
    enforce {
        condition = local.all_groups_valid
        error_message = "CloudFront distribution has improperly configured origin groups. Each origin_group must have: (1) a unique origin_id, (2) failover_criteria with status_codes defined, and (3) at least two member origins (primary and failover)"
    }

    # Enforce: Cache behaviors must reference origin groups
    enforce {
        condition = local.any_behavior_uses_group
        error_message = "CloudFront distribution has origin groups configured but no cache behavior references them. The default_cache_behavior or ordered_cache_behavior must use target_origin_id that matches an origin_group ID (not individual origin IDs) to enable failover"
    }
}
