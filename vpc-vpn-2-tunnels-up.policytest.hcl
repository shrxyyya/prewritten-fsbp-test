# Copyright IBM Corp. 2026

policytest {
  targets = [
    "vpc-vpn-2-tunnels-up.policy.hcl"
  ]
}

# Test 1: PASS - Both tunnels are UP
resource "aws_vpn_connection" "pass_both_tunnels_up" {
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type = "ipsec.1"
    vpn_gateway_id = "vgw-12345678"
    tunnel1_address = "203.0.113.1"
    tunnel2_address = "203.0.113.2"
    vgw_telemetry = [
      {
        status = "UP"
        accepted_route_count = 5
        last_status_change = "2024-01-15T10:30:00Z"
        outside_ip_address = "203.0.113.1"
        status_message = ""
      },
      {
        status = "UP"
        accepted_route_count = 5
        last_status_change = "2024-01-15T10:30:00Z"
        outside_ip_address = "203.0.113.2"
        status_message = ""
      }
    ]
  }
}

# Test 2: FAIL - One tunnel UP, one tunnel DOWN
resource "aws_vpn_connection" "fail_one_tunnel_down" {
  expect_failure = true
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type = "ipsec.1"
    vpn_gateway_id = "vgw-12345678"
    tunnel1_address = "203.0.113.1"
    tunnel2_address = "203.0.113.2"
    vgw_telemetry = [
      {
        status = "UP"
        accepted_route_count = 5
        last_status_change = "2024-01-15T10:30:00Z"
        outside_ip_address = "203.0.113.1"
        status_message = ""
      },
      {
        status = "DOWN"
        accepted_route_count = 0
        last_status_change = "2024-01-15T12:00:00Z"
        outside_ip_address = "203.0.113.2"
        status_message = "IPSEC IS DOWN"
      }
    ]
  }
}

# Test 3: FAIL - Both tunnels DOWN
resource "aws_vpn_connection" "fail_both_tunnels_down" {
  expect_failure = true
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type = "ipsec.1"
    vpn_gateway_id = "vgw-12345678"
    tunnel1_address = "203.0.113.1"
    tunnel2_address = "203.0.113.2"
    vgw_telemetry = [
      {
        status = "DOWN"
        accepted_route_count = 0
        last_status_change = "2024-01-15T12:00:00Z"
        outside_ip_address = "203.0.113.1"
        status_message = "IPSEC IS DOWN"
      },
      {
        status = "DOWN"
        accepted_route_count = 0
        last_status_change = "2024-01-15T12:00:00Z"
        outside_ip_address = "203.0.113.2"
        status_message = "IPSEC IS DOWN"
      }
    ]
  }
}

# Test 4: FAIL - Only one tunnel configured (should have 2)
resource "aws_vpn_connection" "fail_only_one_tunnel" {
  expect_failure = true
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type = "ipsec.1"
    vpn_gateway_id = "vgw-12345678"
    tunnel1_address = "203.0.113.1"
    tunnel2_address = null
    vgw_telemetry = [
      {
        status = "UP"
        accepted_route_count = 5
        last_status_change = "2024-01-15T10:30:00Z"
        outside_ip_address = "203.0.113.1"
        status_message = ""
      }
    ]
  }
}

# Test 5: FILTERED - Empty telemetry array (should be filtered out)
resource "aws_vpn_connection" "filtered_empty_telemetry" {
  attrs = {
    customer_gateway_id = "cgw-12345678"
    type = "ipsec.1"
    vpn_gateway_id = "vgw-12345678"
    tunnel1_address = "203.0.113.1"
    tunnel2_address = "203.0.113.2"
    vgw_telemetry = []
  }
}