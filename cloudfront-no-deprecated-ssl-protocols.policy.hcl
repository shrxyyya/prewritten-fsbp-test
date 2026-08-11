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

input "cloudfront-no-deprecated-ssl-protocols-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cloudfront_distribution" "no_deprecated_ssl_protocols_all" {
    enforcement_level = input.cloudfront-no-deprecated-ssl-protocols-enforcement-level
    # Filter to only distributions with custom origins
    # Skip distributions that only use S3 origins (s3_origin_config)
    filter = attrs.origin != null && core::length(attrs.origin) > 0

    locals {
        # Extract all origins from the distribution
        all_origins = core::try(attrs.origin, [])

        # Filter to only custom origins (those with custom_origin_config)
        custom_origins = [
            for origin in local.all_origins :
            origin if core::try(origin.custom_origin_config, null) != null
        ]

        # Deprecated SSL/TLS protocols for edge -> custom origin communication.
        # Per AWS Security Hub CloudFront.10, only TLSv1.2 and TLSv1.2_2018+ are acceptable.
        deprecated_protocols = ["SSLv3", "TLSv1", "TLSv1_2016"]

        # Check each custom origin for any deprecated protocol in origin_ssl_protocols.
        origins_with_deprecated = [
            for origin in local.custom_origins :
            origin if core::length([
                for p in core::try(origin.custom_origin_config[0].origin_ssl_protocols, []) :
                p if core::contains(local.deprecated_protocols, p)
            ]) > 0
        ]

        # Compliance check
        has_deprecated_ssl = core::try(core::length(local.origins_with_deprecated) > 0, false)

        # Build detailed error message with affected origins
        affected_origins = [
            for origin in local.origins_with_deprecated :
            core::try(origin.domain_name, "unknown")
        ]
    }

    enforce {
        condition = !local.has_deprecated_ssl
        error_message = "CloudFront distribution uses deprecated SSL/TLS protocols (SSLv3, TLSv1, TLSv1_2016) for custom origins: ${core::join(", ", local.affected_origins)}. These protocols are insufficiently secure. Use TLSv1.2_2018, TLSv1.2_2019, or TLSv1.2_2021 for HTTPS communication to custom origins. Update the origin_ssl_protocols configuration to remove deprecated protocols"
    }
}
