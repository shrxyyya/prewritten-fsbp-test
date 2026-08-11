# Copyright IBM Corp. 2026

policytest {
    targets = [
        "emr-security-configuration-encryption-transit.policy.hcl"
    ]
}

# Test 1: PASS - Encryption in transit enabled (true)
resource "aws_emr_security_configuration" "pass_encryption_transit_enabled" {
  attrs = {
    name = "emr-security-config-transit-enabled"
    configuration = <<EOT
{
  "EncryptionConfiguration": {
    "EnableInTransitEncryption": true
  }
}
EOT
  }
}

# Test 2: FAIL - Encryption in transit disabled (false)
resource "aws_emr_security_configuration" "fail_encryption_transit_disabled" {
  expect_failure = true
  attrs = {
    name = "emr-security-config-transit-disabled"
    configuration = <<EOT
{
  "EncryptionConfiguration": {
    "EnableInTransitEncryption": false
  }
}
EOT
  }
}

# Test 3: FAIL - Missing EnableInTransitEncryption attribute
resource "aws_emr_security_configuration" "fail_missing_encryption_transit" {
  expect_failure = true
  attrs = {
    name = "emr-security-config-missing-transit"
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

# Test 5: PASS - Encryption in transit enabled with at-rest encryption
resource "aws_emr_security_configuration" "pass_encryption_transit_with_rest" {
  attrs = {
    name = "emr-security-config-both-encryptions"
    configuration = <<EOT
{
  "EncryptionConfiguration": {
    "EnableInTransitEncryption": true,
    "EnableAtRestEncryption": true
  }
}
EOT
  }
}
