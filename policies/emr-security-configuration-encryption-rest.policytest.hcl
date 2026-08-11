# Copyright IBM Corp. 2026

policytest {
    targets = [
        "emr-security-configuration-encryption-rest.policy.hcl"
    ]
}

# Test 1: PASS - Encryption at rest enabled (true)
resource "aws_emr_security_configuration" "pass_encryption_rest_enabled" {
  attrs = {
    name = "emr-security-config-rest-enabled"
    configuration = <<EOT
{
  "EncryptionConfiguration": {
    "EnableAtRestEncryption": true
  }
}
EOT
  }
}

# Test 2: FAIL - Encryption at rest disabled (false)
resource "aws_emr_security_configuration" "fail_encryption_rest_disabled" {
  expect_failure = true
  attrs = {
    name = "emr-security-config-rest-disabled"
    configuration = <<EOT
{
  "EncryptionConfiguration": {
    "EnableAtRestEncryption": false
  }
}
EOT
  }
}

# Test 3: FAIL - Missing EnableAtRestEncryption attribute
resource "aws_emr_security_configuration" "fail_missing_encryption_rest" {
  expect_failure = true
  attrs = {
    name = "emr-security-config-missing-rest"
    configuration = <<EOT
{
  "EncryptionConfiguration": {}
}
EOT
  }
}

# Test 4: FAIL - Missing EncryptionConfiguration
resource "aws_emr_security_configuration" "fail_missing_encryption_config" {
  expect_failure = true
  attrs = {
    name = "emr-security-config-missing-config"
    configuration = <<EOT
{}
EOT
  }
}

# Test 5: PASS - Encryption at rest enabled with in-transit encryption
resource "aws_emr_security_configuration" "pass_encryption_rest_with_transit" {
  attrs = {
    name = "emr-security-config-both-encryptions"
    configuration = <<EOT
{
  "EncryptionConfiguration": {
    "EnableAtRestEncryption": true,
    "EnableInTransitEncryption": true
  }
}
EOT
  }
}
