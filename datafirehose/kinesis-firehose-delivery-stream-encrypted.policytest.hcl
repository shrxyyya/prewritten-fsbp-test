# Copyright IBM Corp. 2026

policytest {
  targets = [
    "kinesis-firehose-delivery-stream-encrypted.policy.hcl"
  ]
}


# Test 1: Pass - Firehose delivery stream with server-side encryption enabled
resource "aws_kinesis_firehose_delivery_stream" "pass_encryption_enabled" {
  attrs = {
    name = "compliant-stream"
    destination = "extended_s3"
    server_side_encryption = [
      {
        enabled = true
        key_type = "AWS_OWNED_CMK"
      }
    ]
  }
}

# Test 2: Fail - Firehose delivery stream without server-side encryption block
resource "aws_kinesis_firehose_delivery_stream" "fail_no_encryption_block" {
  expect_failure = true
  attrs = {
    name = "non-compliant-stream"
    destination = "extended_s3"
  }
}

# Test 3: Fail - Firehose delivery stream with server-side encryption disabled
resource "aws_kinesis_firehose_delivery_stream" "fail_encryption_disabled" {
  expect_failure = true
  attrs = {
    name = "encryption-disabled-stream"
    destination = "extended_s3"
    server_side_encryption = [
      {
        enabled = false
      }
    ]
  }
}

# Test 4: Pass - Firehose delivery stream with Kinesis stream as source (exception case)
resource "aws_kinesis_firehose_delivery_stream" "pass_kinesis_source_exception" {
  attrs = {
    name = "kinesis-source-stream"
    destination = "extended_s3"
    kinesis_source_configuration = [
      {
        kinesis_stream_arn = "arn:aws:kinesis:us-east-1:123456789012:stream/source-stream"
        role_arn = "arn:aws:iam::123456789012:role/firehose-role"
      }
    ]
  }
}

# Test 5: Pass - Firehose delivery stream with encryption enabled using AWS_OWNED_CMK
resource "aws_kinesis_firehose_delivery_stream" "pass_aws_owned_cmk" {
  attrs = {
    name = "aws-owned-key-stream"
    destination = "extended_s3"
    server_side_encryption = [
      {
        enabled = true
        key_type = "AWS_OWNED_CMK"
      }
    ]
  }
}

# Test 6: Pass - Firehose delivery stream with encryption enabled using CUSTOMER_MANAGED_CMK
resource "aws_kinesis_firehose_delivery_stream" "pass_customer_managed_cmk" {
  attrs = {
    name = "customer-managed-key-stream"
    destination = "extended_s3"
    server_side_encryption = [
      {
        enabled = true
        key_type = "CUSTOMER_MANAGED_CMK"
        key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
      }
    ]
  }
}