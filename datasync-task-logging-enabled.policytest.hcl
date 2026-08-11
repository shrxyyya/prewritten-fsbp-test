# Copyright IBM Corp. 2026

policytest {
  targets = [
    "datasync-task-logging-enabled.policy.hcl"
  ]
}

# Pass case: CloudWatch log group ARN configured with log_level BASIC
resource "aws_datasync_task" "pass_with_basic_logging" {
  attrs = {
    cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/datasync/task"
    source_location_arn = "arn:aws:datasync:us-east-1:123456789012:location/loc-1234567890abcdef0"
    destination_location_arn = "arn:aws:datasync:us-east-1:123456789012:location/loc-abcdef01234567890"
    options = [
      {
        log_level = "BASIC"
      }
    ]
  }
}

# Pass case: CloudWatch log group ARN configured with log_level TRANSFER
resource "aws_datasync_task" "pass_with_transfer_logging" {
  attrs = {
    cloudwatch_log_group_arn = "arn:aws:logs:us-west-2:123456789012:log-group:/aws/datasync/prod"
    source_location_arn = "arn:aws:datasync:us-west-2:123456789012:location/loc-1234567890abcdef0"
    destination_location_arn = "arn:aws:datasync:us-west-2:123456789012:location/loc-abcdef01234567890"
    options = [
      {
        log_level = "TRANSFER"
      }
    ]
  }
}

# Fail case: CloudWatch log group ARN configured but log_level set to OFF
resource "aws_datasync_task" "fail_with_log_level_off" {
  expect_failure = true
  attrs = {
    cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/datasync/task"
    source_location_arn = "arn:aws:datasync:us-east-1:123456789012:location/loc-1234567890abcdef0"
    destination_location_arn = "arn:aws:datasync:us-east-1:123456789012:location/loc-abcdef01234567890"
    options = [
      {
        log_level = "OFF"
      }
    ]
  }
}

# Fail case: No CloudWatch log group ARN configured
resource "aws_datasync_task" "fail_without_log_group" {
  expect_failure = true
  attrs = {
    source_location_arn = "arn:aws:datasync:us-east-1:123456789012:location/loc-1234567890abcdef0"
    destination_location_arn = "arn:aws:datasync:us-east-1:123456789012:location/loc-abcdef01234567890"
    options = [
      {
        log_level = "BASIC"
      }
    ]
  }
}

# Fail case: CloudWatch log group ARN but options block omitted (defaults to OFF)
resource "aws_datasync_task" "fail_with_default_log_level" {
  expect_failure = true
  attrs = {
    cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/datasync/task"
    source_location_arn = "arn:aws:datasync:us-east-1:123456789012:location/loc-1234567890abcdef0"
    destination_location_arn = "arn:aws:datasync:us-east-1:123456789012:location/loc-abcdef01234567890"
  }
}

# Fail case: Empty CloudWatch log group ARN
resource "aws_datasync_task" "fail_with_empty_log_group" {
  expect_failure = true
  attrs = {
    cloudwatch_log_group_arn = ""
    source_location_arn = "arn:aws:datasync:us-east-1:123456789012:location/loc-1234567890abcdef0"
    destination_location_arn = "arn:aws:datasync:us-east-1:123456789012:location/loc-abcdef01234567890"
    options = [
      {
        log_level = "BASIC"
      }
    ]
  }
}