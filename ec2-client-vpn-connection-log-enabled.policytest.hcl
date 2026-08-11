# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ec2-client-vpn-connection-log-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Client VPN endpoint with connection logging enabled
resource "aws_ec2_client_vpn_endpoint" "pass_logging_enabled" {
  attrs = {
    connection_log_options = [{
        enabled = true
    }]
  }
}

# Test 2: FAIL - Client VPN endpoint with connection logging disabled
resource "aws_ec2_client_vpn_endpoint" "fail_logging_disabled" {
  expect_failure = true
  attrs = {
    connection_log_options = [{
        enabled = false
    }]
  }
}

# Test 3: FAIL - Client VPN endpoint with logging explicitly set to false (even with log group)
resource "aws_ec2_client_vpn_endpoint" "fail_logging_explicitly_false" {
  expect_failure = true
  attrs = {
    connection_log_options = [{
        enabled = false
        cloudwatch_log_group = "/aws/vpn/client"
    }]
  }
}

# Test 4: PASS - Client VPN endpoint with logging enabled and CloudWatch log group specified
resource "aws_ec2_client_vpn_endpoint" "pass_logging_with_log_group" {
  attrs = {
    connection_log_options = [{
        enabled = true
        cloudwatch_log_group = "/aws/vpn/client"
        cloudwatch_log_stream = "connection-logs"
    }]
  }
}
