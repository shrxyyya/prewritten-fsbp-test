# Copyright IBM Corp. 2026

# cloudfront-origin-lambda-url-oac-enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cloudfront-origin-lambda-url-oac-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cloudfront_distribution" "lambda_url_oac_required" {
    enforcement_level = input.cloudfront-origin-lambda-url-oac-enabled-enforcement-level
    # Filter to only check distributions that have origins
    filter = attrs.origin != null && core::length(attrs.origin) > 0

    locals {
        # Convert the origin collection to a list for iteration.
        origins = [for origin in attrs.origin : origin]

        # Identify Lambda function URL origins by matching the Lambda URL host pattern.
        # Lambda function URLs are custom origins and use a host like:
        # <url-id>.lambda-url.<region>.on.aws
        lambda_origins = [
            for origin in local.origins :
            origin if (
                core::try(origin.custom_origin_config, null) != null &&
                core::length(core::try(origin.custom_origin_config, [])) > 0 &&
                core::length(
                    core::regexall(
                        "^[^.]+\\.lambda-url\\.[^.]+\\.on\\.aws$",
                        core::trimsuffix(
                            core::trimprefix(
                                core::trimprefix(core::try(origin.domain_name, ""), "https://"),
                                "http://"
                            ),
                            "/"
                        )
                    )
                ) > 0
            )
        ]

        # Check each Lambda origin for OAC
        lambda_origins_without_oac = [
            for origin in local.lambda_origins :
            origin if core::try(origin.origin_access_control_id, null) == null
        ]

        # Check if any Lambda origins exist
        has_lambda_origins = core::length(local.lambda_origins) > 0

        # Check if all Lambda origins have OAC
        all_lambda_origins_have_oac = core::length(local.lambda_origins_without_oac) == 0

        # Build error message with details
        missing_oac_origins = [
            for origin in local.lambda_origins_without_oac :
            core::try(origin.origin_id, "unknown")
        ]
    }

    # Only enforce if there are Lambda function URL origins
    enforce {
        condition = !local.has_lambda_origins || local.all_lambda_origins_have_oac
        error_message = "CloudFront distribution has Lambda function URL origins without origin access control (OAC). Origins missing OAC: ${core::join(", ", local.missing_oac_origins)}"
    }
}