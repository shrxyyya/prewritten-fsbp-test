# Copyright IBM Corp. 2026

policytest {
  targets = [
    "connect-instance-logging-enabled.policy.hcl"
  ]
}
# Test 1: PASS - Connect instance with CloudWatch logging enabled
resource "aws_connect_instance" "pass_logging_enabled" {
  attrs = {
    identity_management_type    = "CONNECT_MANAGED"
    inbound_calls_enabled       = true
    outbound_calls_enabled      = true
    instance_alias              = "my-connect-instance"
    contact_flow_logs_enabled   = true
  }
}

# Test 2: FAIL - Connect instance with CloudWatch logging explicitly disabled
resource "aws_connect_instance" "fail_logging_disabled" {
  expect_failure = true
  attrs = {
    identity_management_type    = "CONNECT_MANAGED"
    inbound_calls_enabled       = true
    outbound_calls_enabled      = true
    instance_alias              = "my-connect-instance"
    contact_flow_logs_enabled   = false
  }
}

# Test 3: FAIL - Connect instance without contact_flow_logs_enabled attribute
resource "aws_connect_instance" "fail_logging_not_specified" {
  expect_failure = true
  attrs = {
    identity_management_type    = "CONNECT_MANAGED"
    inbound_calls_enabled       = true
    outbound_calls_enabled      = true
    instance_alias              = "my-connect-instance"
  }
}