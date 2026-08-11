# Copyright IBM Corp. 2026

policytest {
    targets = [
        "cloud-trail-cloud-watch-logs-enabled.policy.hcl"
    ]
}

# Test 1: PASS - CloudTrail with CloudWatch Logs group ARN configured
resource "aws_cloudtrail" "pass_cloudwatch_logs_enabled" {
  attrs = {
    name                       = "example-trail"
    s3_bucket_name             = "example-bucket"
    cloud_watch_logs_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:cloudtrail-logs:*"
    cloud_watch_logs_role_arn  = "arn:aws:iam::123456789012:role/CloudTrailRole"
    enable_logging             = true
  }
}

# Test 2: FAIL - CloudTrail without CloudWatch Logs group ARN
resource "aws_cloudtrail" "fail_cloudwatch_logs_missing" {
  expect_failure = true
  attrs = {
    name           = "example-trail"
    s3_bucket_name = "example-bucket"
    enable_logging = true
  }
}

# Test 3: FAIL - CloudTrail with empty CloudWatch Logs group ARN
resource "aws_cloudtrail" "fail_cloudwatch_logs_empty" {
  expect_failure = true
  attrs = {
    name                       = "example-trail"
    s3_bucket_name             = "example-bucket"
    cloud_watch_logs_group_arn = ""
    enable_logging             = true
  }
}
