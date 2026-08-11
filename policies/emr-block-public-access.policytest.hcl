# Copyright IBM Corp. 2026

policytest {
    targets = [
        "emr-block-public-access.policy.hcl"
    ]
}

# Test 1: PASS - Block enabled with permitted range 22-22
resource "aws_emr_block_public_access_configuration" "pass_block_enabled_ssh_only" {
  attrs = {
    block_public_security_group_rules = true
    permitted_public_security_group_rule_range = [{
      min_range = 22
      max_range = 22
    }]
  }
}

# Test 2: PASS - Block enabled (default true) with permitted range 22-22
resource "aws_emr_block_public_access_configuration" "pass_default_block_ssh_only" {
  attrs = {
    permitted_public_security_group_rule_range = [{
      min_range = 22
      max_range = 22
    }]
  }
}

# Test 3: FAIL - Block disabled
resource "aws_emr_block_public_access_configuration" "fail_block_disabled" {
  expect_failure = true
  attrs = {
    block_public_security_group_rules = false
    permitted_public_security_group_rule_range = [{
      min_range = 22
      max_range = 22
    }]
  }
}

# Test 4: FAIL - Block enabled but wrong min_range (0-22)
resource "aws_emr_block_public_access_configuration" "fail_wrong_min_range" {
  expect_failure = true
  attrs = {
    block_public_security_group_rules = true
    permitted_public_security_group_rule_range = [{
      min_range = 0
      max_range = 22
    }]
  }
}

# Test 5: FAIL - Block enabled but wrong max_range (22-80)
resource "aws_emr_block_public_access_configuration" "fail_wrong_max_range" {
  expect_failure = true
  attrs = {
    block_public_security_group_rules = true
    permitted_public_security_group_rule_range = [{
      min_range = 22
      max_range = 80
    }]
  }
}

# Test 6: FAIL - Block enabled but both ranges wrong (0-65535)
resource "aws_emr_block_public_access_configuration" "fail_all_ports" {
  expect_failure = true
  attrs = {
    block_public_security_group_rules = true
    permitted_public_security_group_rule_range = [{
      min_range = 0
      max_range = 65535
    }]
  }
}

# Test 7: FAIL - Block enabled but missing permitted range
resource "aws_emr_block_public_access_configuration" "fail_missing_range" {
  expect_failure = true
  attrs = {
    block_public_security_group_rules = true
  }
}

# Test 8: FAIL - Block enabled with only min_range specified
resource "aws_emr_block_public_access_configuration" "fail_only_min_range" {
  expect_failure = true
  attrs = {
    block_public_security_group_rules = true
    permitted_public_security_group_rule_range = [{
      min_range = 22
    }]
  }
}

# Test 9: FAIL - Block enabled with only max_range specified
resource "aws_emr_block_public_access_configuration" "fail_only_max_range" {
  expect_failure = true
  attrs = {
    block_public_security_group_rules = true
    permitted_public_security_group_rule_range = [{
      max_range = 22
    }]
  }
}
