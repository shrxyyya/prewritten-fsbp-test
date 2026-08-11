# Copyright IBM Corp. 2026

# Policy: CloudFront.10 - CloudFront distributions should not use SSLv3 between edge locations and custom origins

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cloudfront-no-sslv3-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cloudfront_distribution" "no_deprecated_ssl_protocols" {
    enforcement_level = input.cloudfront-no-sslv3-enforcement-level
    # Filter to only distributions with custom origins
    # Skip distributions that only use S3 origins (s3_origin_config)
    filter = attrs.origin != null && core::length(attrs.origin) > 0

    locals {
        # Extract all origins from the distribution
        all_origins = core::try(attrs.origin, [])

        # Filter to only custom origins (those with custom_origin_config).
        # S3 origins use s3_origin_config and are out of scope for CloudFront.10.
        custom_origins = [
            for origin in local.all_origins :
            origin if core::try(origin.custom_origin_config, null) != null
        ]

        origins_with_sslv3 = [
            for origin in local.custom_origins :
            origin if core::contains(
                core::try(origin.custom_origin_config[0].origin_ssl_protocols, []),
                "SSLv3"
            )
        ]

        # Compliance check
        has_deprecated_ssl = core::length(local.origins_with_sslv3) > 0

        # Build detailed error message with affected origins
        affected_origins = [
            for origin in local.origins_with_sslv3 :
            core::try(origin.domain_name, "unknown")
        ]
    }

    enforce {
        condition = !local.has_deprecated_ssl
        error_message = "CloudFront distribution uses deprecated SSLv3 protocol for custom origins: ${core::join(", ", local.affected_origins)}. SSLv3 is insufficiently secure and should not be used. Use TLSv1.2 or later for HTTPS communication to custom origins. Update the origin_ssl_protocols configuration to remove 'SSLv3'"
    }
}
