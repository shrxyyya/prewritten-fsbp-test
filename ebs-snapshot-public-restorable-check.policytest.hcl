# Copyright IBM Corp. 2026

policytest {
  targets = ["ebs-snapshot-public-restorable-check.policy.hcl"]
}

# Test 1: PASS - Block public access configured with 'block-all-sharing'
resource "aws_ebs_snapshot_block_public_access" "pass_block_all_sharing" {
  attrs = {
    state = "block-all-sharing"
  }
}

# Test 2: PASS - Block public access configured with 'block-new-sharing'
resource "aws_ebs_snapshot_block_public_access" "pass_block_new_sharing" {
  attrs = {
    state = "block-new-sharing"
  }
}

# Test 3: FAIL - Block public access configured with 'unblocked'
resource "aws_ebs_snapshot_block_public_access" "fail_unblocked_state" {
  expect_failure = true
  attrs = {
    state = "unblocked"
  }
}

# Test 4: FAIL - Invalid state value (empty string)
resource "aws_ebs_snapshot_block_public_access" "fail_empty_state" {
  expect_failure = true
  attrs = {
    state = ""
  }
}

# Test 5: FAIL - Invalid state value (random string)
resource "aws_ebs_snapshot_block_public_access" "fail_invalid_state" {
  expect_failure = true
  attrs = {
    state = "invalid-state"
  }
}

# Test 6: PASS - Block configuration with optional region attribute
resource "aws_ebs_snapshot_block_public_access" "pass_with_region" {
  attrs = {
    state = "block-all-sharing"
    region = "us-east-1"
  }
}

# Test 7: PASS - Another valid configuration with block-new-sharing and region
resource "aws_ebs_snapshot_block_public_access" "pass_block_new_with_region" {
  attrs = {
    state = "block-new-sharing"
    region = "us-west-2"
  }
}
