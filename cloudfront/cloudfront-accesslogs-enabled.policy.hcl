# Copyright IBM Corp. 2026

# CloudFront distributions should have logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cloudfront-accesslogs-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cloudfront_distribution" "logging_required" {
    enforcement_level = input.cloudfront-accesslogs-enabled-enforcement-level
    # Pre-filter to only evaluate enabled distributions
    filter = core::try(attrs.enabled, false) == true

    locals {
        # Safe access to logging_config block
        # logging_config is a block (list of maps), so we need [0] indexing
        logging_config = core::try(attrs.logging_config[0], null)
        
        # Check if logging is configured with a bucket
        has_logging_config = local.logging_config != null
        
        # Extract bucket value safely
        bucket = core::try(local.logging_config.bucket, "")
        
        # Validate bucket is non-empty (check string is not empty)
        has_valid_bucket = local.has_logging_config && local.bucket != ""
    }

    enforce {
        condition = local.has_valid_bucket
        error_message = "CloudFront distribution must have logging enabled. Configure the logging_config block with a valid S3 bucket (e.g., logging_config { bucket = \"myawslogbucket.s3.amazonaws.com\" })"
    }
}
