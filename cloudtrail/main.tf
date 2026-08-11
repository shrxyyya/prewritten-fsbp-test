terraform {
  required_version = ">= 1.15.0"

  cloud {

    organization = "nagateja-test-org"

    workspaces {
      name = "provider-test"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket = "example-cloudtrail-logs"
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name = "/aws/cloudtrail/example"
}

resource "aws_kms_key" "cloudtrail" {
  description             = "KMS key for CloudTrail encryption"
  deletion_window_in_days = 7
}

resource "aws_cloudtrail" "example" {
  name                          = "example-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id

  # cloud-trail-cloud-watch-logs-enabled: CloudWatch Logs integration
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"

  # cloud-trail-encryption-enabled: KMS encryption at rest
  kms_key_id = aws_kms_key.cloudtrail.arn

  # cloud-trail-log-file-validation-enabled: log file integrity validation
  enable_log_file_validation = true

  # multi-region-cloudtrail-enabled: must be multi-region and logging enabled
  is_multi_region_trail = true
  enable_logging        = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}
