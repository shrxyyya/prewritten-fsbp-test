# Copyright IBM Corp. 2026

policytest {
  targets = [
    "vpc-flow-logs-enabled.policy.hcl"
  ]
}

# Test 1: VPC with flow logging enabled (REJECT traffic type) - Should PASS
resource "aws_flow_log" "reject_flow_log" {
  attrs = {
    vpc_id       = "vpc-pass-reject"
    traffic_type = "REJECT"
  }
}

resource "aws_vpc" "vpc_with_reject_logging" {
  attrs = {
    id         = "vpc-pass-reject"
    cidr_block = "10.0.0.0/16"
  }
}

# Test 2: VPC with flow logging enabled (ALL traffic type) - Should FAIL
resource "aws_flow_log" "all_flow_log" {
  attrs = {
    vpc_id       = "vpc-pass-all"
    traffic_type = "ALL"
  }
}

resource "aws_vpc" "vpc_with_all_logging" {
  expect_failure = true
  attrs = {
    id         = "vpc-pass-all"
    cidr_block = "10.1.0.0/16"
  }
}

# Test 3: VPC without any flow logging - Should FAIL
resource "aws_vpc" "vpc_without_logging" {
  expect_failure = true
  attrs = {
    id         = "vpc-fail-no-log"
    cidr_block = "10.2.0.0/16"
  }
}

# Test 4: VPC with flow logging but ACCEPT traffic type only - Should FAIL
resource "aws_flow_log" "accept_flow_log" {
  attrs = {
    vpc_id       = "vpc-fail-accept"
    traffic_type = "ACCEPT"
  }
}

resource "aws_vpc" "vpc_with_accept_only" {
  expect_failure = true
  attrs = {
    id         = "vpc-fail-accept"
    cidr_block = "10.3.0.0/16"
  }
}
