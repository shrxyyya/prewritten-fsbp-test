# Copyright IBM Corp. 2026

# CloudFront distributions should not point to non-existent S3 origins

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cloudfront-s3-origin-non-existent-bucket-enforcement-level" {
  type = string
  default = "advisory"
}

# Cache all S3 buckets once for performance
locals {
  all_s3_buckets = core::getresources("aws_s3_bucket", {})
  
  # Extract bucket names for lookup
  bucket_names = [for bucket in local.all_s3_buckets : bucket.bucket]
}

resource_policy "aws_cloudfront_distribution" "no_nonexistent_s3_origins" {
  enforcement_level = input.cloudfront-s3-origin-non-existent-bucket-enforcement-level
  
  locals {
    # Extract all origins from the distribution
    origins = core::try(attrs.origin, [])

    # Filter to likely S3 origins: those that do NOT have custom_origin_config.
    # This covers both legacy OAI-style (s3_origin_config present) and modern
    # OAC-style origins (origin_access_control_id, no s3_origin_config).
    # Origins with custom_origin_config are custom/HTTP origins (e.g. ALBs,
    # S3 website endpoints) and are excluded per the AWS Config rule intent.
    s3_origins = core::try([
      for origin in local.origins :
      origin if core::try(origin.custom_origin_config, null) == null
    ], [])

    # CloudFront origin.domain_name for S3 origins looks like:
    #   my-bucket.s3.amazonaws.com
    #   my-bucket.s3.us-east-1.amazonaws.com
    # The bucket name is the first label of that domain. Extract it so we
    # can compare against aws_s3_bucket.bucket (which is just "my-bucket").
    invalid_origin_buckets = [
      for origin in local.s3_origins :
      core::try(core::split(".", core::try(origin.domain_name, ""))[0], "")
      if !core::contains(
        local.bucket_names,
        core::try(core::split(".", core::try(origin.domain_name, ""))[0], "")
      )
    ]

    # Check if all S3 origins resolve to a known bucket
    all_origins_valid = core::length(local.invalid_origin_buckets) == 0
  }
  
  # Only evaluate distributions that have S3 origins
  filter = core::length(local.s3_origins) > 0
  
  enforce {
    condition = local.all_origins_valid
    error_message = "CloudFront distribution points to non-existent S3 origin bucket(s): ${core::join(", ", local.invalid_origin_buckets)}. All S3 origins must reference buckets defined in the Terraform configuration to prevent malicious third parties from creating the bucket and serving unauthorized content"
  }
}
