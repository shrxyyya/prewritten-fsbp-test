# Copyright IBM Corp. 2026

policytest {
    targets = [
        "cloud-trail-encryption-enabled.policy.hcl"
    ]
}

# Test 1: PASS - CloudTrail with KMS encryption enabled
resource "aws_cloudtrail" "pass_encryption_enabled" {
  attrs = {
    name           = "encrypted-trail"
    s3_bucket_name = "example-bucket"
    kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    enable_logging = true
  }
}

# Test 2: FAIL - CloudTrail without KMS encryption
resource "aws_cloudtrail" "fail_encryption_missing" {
  expect_failure = true
  attrs = {
    name           = "unencrypted-trail"
    s3_bucket_name = "example-bucket"
    enable_logging = true
  }
}

# Test 3: FAIL - CloudTrail with empty KMS key ID
resource "aws_cloudtrail" "fail_encryption_empty" {
  expect_failure = true
  attrs = {
    name           = "trail-empty-kms"
    s3_bucket_name = "example-bucket"
    kms_key_id     = ""
    enable_logging = true
  }
}

# Test 4: PASS - CloudTrail with KMS key alias
resource "aws_cloudtrail" "pass_encryption_with_alias" {
  attrs = {
    name           = "encrypted-trail-alias"
    s3_bucket_name = "example-bucket"
    kms_key_id     = "alias/cloudtrail-key"
    enable_logging = true
  }
}
