# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ec2-imdsv2-check.policy.hcl"
    ]
}

# Test 1: PASS - IMDSv2 is enabled
resource "aws_ec2_instance_metadata_defaults" "imds_v2_enabled" {
    attrs = {
        http_tokens = "required"
    }
}

# Test 2: FAIL - IMDSv2 is not enabled
resource "aws_ec2_instance_metadata_defaults" "imds_v2_disabled" {
    expect_failure = true
    attrs = {
        http_tokens = "optional"
    }
}

# Test 3: PASS - IMDSv2 is not configured
resource "aws_ec2_instance_metadata_defaults" "imds_v2_undefined" {
    attrs = {}
}