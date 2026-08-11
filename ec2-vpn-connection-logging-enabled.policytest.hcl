# Copyright IBM Corp. 2026

policytest { 
    targets = [
        "ec2-vpn-connection-logging-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Both tunnels have logging enabled with log group ARNs configured
resource "aws_vpn_connection" "pass_both_tunnels_logging_enabled" {
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type                = "ipsec.1"
    tunnel1_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = true
            log_group_arn    = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpn/tunnel1"
            log_output_format = "json"
          }
        ]
      }
    ]
    tunnel2_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = true
            log_group_arn    = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpn/tunnel2"
            log_output_format = "json"
          }
        ]
      }
    ]
  }
}

# Test 2: FAIL - Tunnel1 logging disabled
resource "aws_vpn_connection" "fail_tunnel1_logging_disabled" {
  expect_failure = true
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type                = "ipsec.1"
    tunnel1_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = false
            log_group_arn    = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpn/tunnel1"
            log_output_format = "json"
          }
        ]
      }
    ]
    tunnel2_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = true
            log_group_arn    = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpn/tunnel2"
            log_output_format = "json"
          }
        ]
      }
    ]
  }
}

# Test 3: FAIL - Tunnel2 logging disabled
resource "aws_vpn_connection" "fail_tunnel2_logging_disabled" {
  expect_failure = true
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type                = "ipsec.1"
    tunnel1_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = true
            log_group_arn    = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpn/tunnel1"
            log_output_format = "json"
          }
        ]
      }
    ]
    tunnel2_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = false
            log_group_arn    = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpn/tunnel2"
            log_output_format = "json"
          }
        ]
      }
    ]
  }
}

# Test 4: FAIL - Both tunnels logging disabled
resource "aws_vpn_connection" "fail_both_tunnels_logging_disabled" {
  expect_failure = true
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type                = "ipsec.1"
    tunnel1_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = false
            log_group_arn    = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpn/tunnel1"
            log_output_format = "json"
          }
        ]
      }
    ]
    tunnel2_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = false
            log_group_arn    = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpn/tunnel2"
            log_output_format = "json"
          }
        ]
      }
    ]
  }
}

# Test 5: FAIL - Tunnel1 log group ARN is empty
resource "aws_vpn_connection" "fail_tunnel1_empty_log_group_arn" {
  expect_failure = true
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type                = "ipsec.1"
    tunnel1_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = true
            log_group_arn    = ""
            log_output_format = "text"
          }
        ]
      }
    ]
    tunnel2_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = true
            log_group_arn    = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpn/tunnel2"
            log_output_format = "text"
          }
        ]
      }
    ]
  }
}

# Test 6: FAIL - Tunnel2 log group ARN is empty
resource "aws_vpn_connection" "fail_tunnel2_empty_log_group_arn" {
  expect_failure = true
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type                = "ipsec.1"
    tunnel1_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = true
            log_group_arn    = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpn/tunnel1"
            log_output_format = "text"
          }
        ]
      }
    ]
    tunnel2_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = true
            log_group_arn    = ""
            log_output_format = "text"
          }
        ]
      }
    ]
  }
}

# Test 7: FAIL - Both tunnels have empty log group ARNs
resource "aws_vpn_connection" "fail_both_empty_log_group_arns" {
  expect_failure = true
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type                = "ipsec.1"
    tunnel1_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = true
            log_group_arn    = ""
          }
        ]
      }
    ]
    tunnel2_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = true
            log_group_arn    = ""
          }
        ]
      }
    ]
  }
}

# Test 8: FAIL - Tunnel1 log_options is empty array
resource "aws_vpn_connection" "fail_tunnel1_empty_log_options" {
  expect_failure = true
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type                = "ipsec.1"
    tunnel1_log_options = []
    tunnel2_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = true
            log_group_arn    = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpn/tunnel2"
          }
        ]
      }
    ]
  }
}

# Test 9: FAIL - Tunnel2 log_options is empty array
resource "aws_vpn_connection" "fail_tunnel2_empty_log_options" {
  expect_failure = true
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type                = "ipsec.1"
    tunnel1_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = true
            log_group_arn    = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpn/tunnel1"
          }
        ]
      }
    ]
    tunnel2_log_options = []
  }
}

# Test 10: FAIL - Both tunnels have empty log_options arrays
resource "aws_vpn_connection" "fail_both_empty_log_options" {
  expect_failure = true
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type                = "ipsec.1"
    tunnel1_log_options = []
    tunnel2_log_options = []
  }
}

# Test 11: FAIL - Tunnel1 log_options not specified (missing attribute)
resource "aws_vpn_connection" "fail_tunnel1_missing_log_options" {
  expect_failure = true
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type                = "ipsec.1"
    tunnel2_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = true
            log_group_arn    = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpn/tunnel2"
          }
        ]
      }
    ]
  }
}

# Test 12: FAIL - Tunnel2 log_options not specified (missing attribute)
resource "aws_vpn_connection" "fail_tunnel2_missing_log_options" {
  expect_failure = true
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type                = "ipsec.1"
    tunnel1_log_options = [
      {
        cloudwatch_log_options = [
          {
            log_enabled      = true
            log_group_arn    = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpn/tunnel1"
          }
        ]
      }
    ]
  }
}

# Test 13: FAIL - Both tunnels log_options not specified (missing attributes)
resource "aws_vpn_connection" "fail_both_missing_log_options" {
  expect_failure = true
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type                = "ipsec.1"
  }
}
