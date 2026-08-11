# Copyright IBM Corp. 2026

policytest {
    targets = [
        "alb-http-drop-invalid-header-enabled.policy.hcl"
    ]
}

# Test 1: PASS - drop_invalid_header_fields is set to true
resource "aws_lb" "application_lb_compliant" {
  attrs = {
    load_balancer_type         = "application"
    drop_invalid_header_fields = true
    name                       = "compliant-alb"
  }
}

# Test 2: FAIL - drop_invalid_header_fields is set to false
resource "aws_lb" "application_lb_non_compliant" {
  expect_failure = true
  attrs = {
    load_balancer_type         = "application"
    drop_invalid_header_fields = false
    name                       = "non-compliant-alb"
  }
}

# Test 3: FAIL - drop_invalid_header_fields is missing (defaults to false)
resource "aws_lb" "application_lb_non_compliant" {
  expect_failure = true
  attrs = {
    load_balancer_type         = "application"
    name                       = "non-compliant-alb"
  }
}

# Test 4: SKIP - Load_balancer_type is not 'application'
resource "aws_lb" "network_lb_not_applicable" {
  attrs = {
    load_balancer_type         = "network"
    drop_invalid_header_fields = false
    name                       = "network-lb"
  }
}
