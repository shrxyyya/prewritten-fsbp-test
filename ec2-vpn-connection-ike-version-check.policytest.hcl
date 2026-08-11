# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ec2-vpn-connection-ike-version-check.policy.hcl"
  ]
}

# Test 1: PASS - Both tunnels explicitly restrict to IKEv2 only
resource "aws_vpn_connection" "pass_ikev2_only" {
  attrs = {
    id                  = "vpn-pass-ikev2"
    customer_gateway_id = "cgw-12345678"
    vpn_gateway_id      = "vgw-12345678"
    type                = "ipsec.1"
    tunnel1_ike_versions = ["ikev2"]
    tunnel2_ike_versions = ["ikev2"]
  }
}

# Test 2: FAIL - Tunnel 1 allows IKEv1
resource "aws_vpn_connection" "fail_tunnel1_allows_ikev1" {
  expect_failure = true
  attrs = {
    id                  = "vpn-fail-tunnel1-ikev1"
    customer_gateway_id = "cgw-12345678"
    vpn_gateway_id      = "vgw-12345678"
    type                = "ipsec.1"
    tunnel1_ike_versions = ["ikev1", "ikev2"]
    tunnel2_ike_versions = ["ikev2"]
  }
}

# Test 3: FAIL - Tunnel 2 allows IKEv1 only
resource "aws_vpn_connection" "fail_tunnel2_ikev1_only" {
  expect_failure = true
  attrs = {
    id                  = "vpn-fail-tunnel2-ikev1"
    customer_gateway_id = "cgw-12345678"
    vpn_gateway_id      = "vgw-12345678"
    type                = "ipsec.1"
    tunnel1_ike_versions = ["ikev2"]
    tunnel2_ike_versions = ["ikev1"]
  }
}

# Test 4: FAIL - Tunnel 1 does not explicitly restrict IKE version
resource "aws_vpn_connection" "fail_tunnel1_not_specified" {
  expect_failure = true
  attrs = {
    id                  = "vpn-fail-tunnel1-missing"
    customer_gateway_id = "cgw-12345678"
    vpn_gateway_id      = "vgw-12345678"
    type                = "ipsec.1"
    tunnel2_ike_versions = ["ikev2"]
  }
}

# Test 5: FAIL - Tunnel 2 does not explicitly restrict IKE version
resource "aws_vpn_connection" "fail_tunnel2_not_specified" {
  expect_failure = true
  attrs = {
    id                  = "vpn-fail-tunnel2-missing"
    customer_gateway_id = "cgw-12345678"
    vpn_gateway_id      = "vgw-12345678"
    type                = "ipsec.1"
    tunnel1_ike_versions = ["ikev2"]
  }
}

# Test 6: PASS - ipsec.2 VPN connection with IKEv2-only tunnels
# (validates that the policy no longer filters on type == "ipsec.1")
resource "aws_vpn_connection" "pass_ipsec2_ikev2_only" {
  attrs = {
    id                   = "vpn-pass-ipsec2"
    customer_gateway_id  = "cgw-12345678"
    vpn_gateway_id       = "vgw-12345678"
    type                 = "ipsec.2"
    tunnel1_ike_versions = ["ikev2"]
    tunnel2_ike_versions = ["ikev2"]
  }
}

# Test 7: FAIL - ipsec.2 VPN connection with IKEv1 allowed on tunnel 1
resource "aws_vpn_connection" "fail_ipsec2_tunnel1_mixed" {
  expect_failure = true
  attrs = {
    id                   = "vpn-fail-ipsec2-mixed"
    customer_gateway_id  = "cgw-12345678"
    vpn_gateway_id       = "vgw-12345678"
    type                 = "ipsec.2"
    tunnel1_ike_versions = ["ikev1", "ikev2"]
    tunnel2_ike_versions = ["ikev2"]
  }
}

# Test 8: FAIL - both tunnels omit ike_versions
# AWS default is ["ikev1", "ikev2"] — non-compliant.
resource "aws_vpn_connection" "fail_no_ike_versions_set" {
  expect_failure = true
  attrs = {
    id                  = "vpn-fail-default"
    customer_gateway_id = "cgw-12345678"
    vpn_gateway_id      = "vgw-12345678"
    type                = "ipsec.1"
  }
}
