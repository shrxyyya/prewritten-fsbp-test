# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ec2-ebs-encryption-by-default.policy.hcl"
    ]
}

# Test 1: PASS - Resource with enabled = true
resource "aws_ebs_encryption_by_default" "enabled_true" {
  attrs = {
    enabled = true
  }
}

# Test 2: FAIL - Resource with enabled = false
resource "aws_ebs_encryption_by_default" "enabled_false" {
  expect_failure = true
  attrs = {
    enabled = false
  }
}

# Test 3: PASS - Resource without enabled attribute (defaults to false)
resource "aws_ebs_encryption_by_default" "no_enabled_attr" {
  attrs = {}
}
