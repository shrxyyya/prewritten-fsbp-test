# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ebs-snapshot-block-public-access.policy.hcl"
    ]
}

# Test 1: PASS - state = "block-all-sharing" (compliant)
resource "aws_ebs_snapshot_block_public_access" "pass_with_block_all_sharing" {
  attrs = {
    state = "block-all-sharing"
  }
}

# Test 2: FAIL - state = "block-new-sharing" (not strict enough)
resource "aws_ebs_snapshot_block_public_access" "fail_with_block_new_sharing" {
  expect_failure = true
  attrs = {
    state = "block-new-sharing"
  }
}

# Test 3: FAIL - state = "unblocked" (public sharing allowed)
resource "aws_ebs_snapshot_block_public_access" "fail_with_unblocked" {
  expect_failure = true
  attrs = {
    state = "unblocked"
  }
}

# Test 4: FAIL - state attribute missing (not explicitly configured)
resource "aws_ebs_snapshot_block_public_access" "fail_with_missing_state" {
  expect_failure = true
  attrs = {
    region = "us-east-1"
  }
}
