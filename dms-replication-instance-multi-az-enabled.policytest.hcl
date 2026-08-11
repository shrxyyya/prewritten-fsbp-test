# Copyright IBM Corp. 2026

policytest {
    targets = [
        "dms-replication-instance-multi-az-enabled.policy.hcl"
    ]
}

# Test 1: PASS - multi_az is true
resource "aws_dms_replication_instance" "pass_multi_az_true" {
    attrs = {
        multi_az = true
    }
}

# Test 2: FAIL - multi_az is false
resource "aws_dms_replication_instance" "fail_multi_az_false" {
    expect_failure = true
    attrs = {
        multi_az = false
    }
}

# Test 3: FAIL - multi_az is not present
resource "aws_dms_replication_instance" "fail_multi_az_missing" {
    expect_failure = true
    attrs = {
        engine_version = "3.1.4"
        # multi_az is omitted
    }
}