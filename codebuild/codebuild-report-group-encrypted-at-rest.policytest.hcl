# Copyright IBM Corp. 2026

policytest {
  targets = [
    "codebuild-report-group-encrypted-at-rest.policy.hcl"
  ]
}
# Test 1: PASS - Report group with S3 export and KMS encryption key
resource "aws_codebuild_report_group" "pass_with_kms_encryption" {
  attrs = {
    name = "test-report-group"
    type = "TEST"
    export_config = [
      {
        type = "S3"
        s3_destination = [
          {
            bucket = "my-reports-bucket"
            encryption_key = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
            encryption_disabled = false
            packaging = "ZIP"
            path = "/reports"
          }
        ]
      }
    ]
  }
}

# Test 2: FAIL - Report group with S3 export but no encryption key
resource "aws_codebuild_report_group" "fail_missing_encryption_key" {
  expect_failure = true
  attrs = {
    name = "test-report-group-no-key"
    type = "TEST"
    export_config = [
      {
        type = "S3"
        s3_destination = [
          {
            bucket = "my-reports-bucket"
            encryption_key = ""
            packaging = "ZIP"
            path = "/reports"
          }
        ]
      }
    ]
  }
}

# Test 3: FAIL - Report group with encryption explicitly disabled
resource "aws_codebuild_report_group" "fail_encryption_disabled" {
  expect_failure = true
  attrs = {
    name = "test-report-group-disabled"
    type = "TEST"
    export_config = [
      {
        type = "S3"
        s3_destination = [
          {
            bucket = "my-reports-bucket"
            encryption_key = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
            encryption_disabled = true
            packaging = "ZIP"
            path = "/reports"
          }
        ]
      }
    ]
  }
}

# Test 4: FAIL - Report group with S3 export but no s3_destination
resource "aws_codebuild_report_group" "fail_no_s3_destination" {
  expect_failure = true
  attrs = {
    name = "test-report-group-no-dest"
    type = "TEST"
    export_config = [
      {
        type = "S3"
        s3_destination = []
      }
    ]
  }
}

# Test 5: PASS - Report group with NO_EXPORT (filtered out by policy)
resource "aws_codebuild_report_group" "pass_no_export_filtered" {
  skip = true
  attrs = {
    name = "test-report-group-no-export"
    type = "TEST"
    export_config = [
      {
        type = "NO_EXPORT"
      }
    ]
  }
}