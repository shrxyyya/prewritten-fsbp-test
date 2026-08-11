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

resource "aws_cloudwatch_log_group" "datasync" {
  name = "/aws/datasync/example"
}

resource "aws_datasync_location_s3" "source" {
  s3_bucket_arn = "arn:aws:s3:::example-datasync-source"
  subdirectory  = "/source"

  s3_config {
    bucket_access_role_arn = "arn:aws:iam::123456789012:role/datasync-s3-role"
  }
}

resource "aws_datasync_location_s3" "destination" {
  s3_bucket_arn = "arn:aws:s3:::example-datasync-destination"
  subdirectory  = "/destination"

  s3_config {
    bucket_access_role_arn = "arn:aws:iam::123456789012:role/datasync-s3-role"
  }
}

resource "aws_datasync_task" "example" {
  name                     = "example-task"
  source_location_arn      = aws_datasync_location_s3.source.arn
  destination_location_arn = aws_datasync_location_s3.destination.arn

  # datasync-task-logging-enabled: CloudWatch log group ARN must be set
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.datasync.arn

  options {
    # datasync-task-logging-enabled: log_level must not be OFF
    log_level = "TRANSFER"
  }
}
