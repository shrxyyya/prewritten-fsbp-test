# Copyright IBM Corp. 2026

# CloudFront distributions should use origin access control

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.29.0, < 7.0.0"
    }
  }
}

input "cloudfront-s3-origin-access-control-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

# Cache all OAC resources for efficient lookup
locals {
    all_oac_resources = core::getresources("aws_cloudfront_origin_access_control", {})
    all_bucket_policies = core::getresources("aws_s3_bucket_policy", {})
}

resource_policy "aws_cloudfront_distribution" "oac_required" {
    enforcement_level = input.cloudfront-s3-origin-access-control-enabled-enforcement-level

    locals {
        # core::try handles missing attribute (error). Wrapping length in core::try
        # also handles explicit null — core::length(null) would error, returning false.
        origins = core::try(attrs.origin, [])
        has_origins = core::try(core::length(local.origins) > 0, false)

        # Identify likely S3 origins: origins that do NOT have custom_origin_config.
        # Wrap the for-expression in core::try so that a null origins value (explicit null)
        # does not propagate — it is caught and returns [] instead.
        # Ternary is avoided here because it requires both branches to have the same
        # tuple type, which fails when attrs.origin is a multi-element tuple vs [].
        likely_s3_origins = core::try([
            for origin in local.origins :
            origin if core::try(origin.custom_origin_config, null) == null
        ], [])

        # Check if there are any likely S3 origins
        has_likely_s3_origins = core::length(local.likely_s3_origins) > 0

        # S3 origins with OAC configured.
        # Check for both null and "" because core::try passes explicit null values through
        # (it only catches errors, not nulls), so origin_access_control_id = null returns
        # null rather than "".
        s3_origins_with_oac = [
            for origin in local.likely_s3_origins :
            origin if core::try(origin.origin_access_control_id, null) != null && core::try(origin.origin_access_control_id, "") != ""
        ]

        # S3 origins without OAC
        s3_origins_without_oac = [
            for origin in local.likely_s3_origins :
            origin if core::try(origin.origin_access_control_id, null) == null || core::try(origin.origin_access_control_id, "") == ""
        ]

        # Check if all S3 origins have OAC
        all_s3_origins_have_oac = local.has_likely_s3_origins && core::length(local.s3_origins_with_oac) == core::length(local.likely_s3_origins)

        # Create list of origin IDs missing OAC for error message
        missing_oac_origin_ids = [
            for origin in local.s3_origins_without_oac :
            core::try(origin.origin_id, "unknown")
        ]
    }

    # Enforce: Distribution must have at least one origin configured
    enforce {
        condition = local.has_origins
        error_message = "CloudFront distribution has no origins configured (origin is null or empty). At least one origin must be defined"
    }

    # Enforce: All S3 origins (those without custom_origin_config) must have OAC configured
    enforce {
        condition = !local.has_likely_s3_origins || local.all_s3_origins_have_oac
        error_message = "CloudFront distribution has origins without origin access control (OAC). Origins missing OAC: ${core::join(", ", local.missing_oac_origin_ids)}. Configure origin_access_control_id for all S3 origins to restrict access through CloudFront only"
    }
}

resource_policy "aws_cloudfront_origin_access_control" "proper_configuration" {
    enforcement_level = input.cloudfront-s3-origin-access-control-enabled-enforcement-level
    # Only evaluate OACs scoped to S3 origins. Other origin types (lambda,
    # mediastore, mediapackagev2) are out of scope for CloudFront.13 and are
    # covered by their own policies.
    filter = core::try(attrs.origin_access_control_origin_type, "") == "s3"

    locals {
        # Safe access to signing_behavior - default to empty string if missing or null
        signing_behavior = core::try(attrs.signing_behavior, null) != null ? attrs.signing_behavior : ""
        has_valid_signing_behavior = local.signing_behavior == "always"

        # Safe access to signing_protocol - default to empty string if missing or null
        signing_protocol = core::try(attrs.signing_protocol, null) != null ? attrs.signing_protocol : ""
        has_valid_signing_protocol = local.signing_protocol == "sigv4"
    }

    # Enforce: OAC must have signing_behavior set to "always"
    enforce {
        condition = local.has_valid_signing_behavior
        error_message = "Origin Access Control must have signing_behavior set to 'always' (current: '${local.signing_behavior}'). This ensures CloudFront always signs requests to the S3 origin"
    }

    # Enforce: OAC must have signing_protocol set to "sigv4"
    enforce {
        condition = local.has_valid_signing_protocol
        error_message = "Origin Access Control must have signing_protocol set to 'sigv4' (current: '${local.signing_protocol}'). SigV4 is required for secure authentication with S3"
    }
}

