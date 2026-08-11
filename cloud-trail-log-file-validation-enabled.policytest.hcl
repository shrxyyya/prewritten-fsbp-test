# Copyright IBM Corp. 2026

policytest {
    targets = [
        "cloud-trail-log-file-validation-enabled.policy.hcl"
    ]
}

# Test 1: PASS - CloudTrail with log file validation enabled
resource "aws_cloudtrail" "pass_log_validation_enabled" {
  attrs = {
    name                          = "validated-trail"
    s3_bucket_name                = "example-bucket"
    enable_log_file_validation    = true
    enable_logging                = true
  }
}

# Test 2: FAIL - CloudTrail with log file validation disabled
resource "aws_cloudtrail" "fail_log_validation_disabled" {
  expect_failure = true
  attrs = {
    name                          = "unvalidated-trail"
    s3_bucket_name                = "example-bucket"
    enable_log_file_validation    = false
    enable_logging                = true
  }
}

# Test 3: FAIL - CloudTrail without log file validation attribute
resource "aws_cloudtrail" "fail_log_validation_missing" {
  expect_failure = true
  attrs = {
    name           = "trail-no-validation"
    s3_bucket_name = "example-bucket"
    enable_logging = true
  }
}
