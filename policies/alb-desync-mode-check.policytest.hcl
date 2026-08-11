# Copyright IBM Corp. 2026

policytest {
    targets = [
        "alb-desync-mode-check.policy.hcl"
    ]
}

# Test 1: PASS - ALB with defensive mode (explicit)
resource "aws_lb" "compliant_defensive" {
  attrs = {
    load_balancer_type = "application"
    desync_mitigation_mode = "defensive"
    name = "test-alb-defensive"
  }
}

# Test 2: PASS - ALB with strictest mode
resource "aws_lb" "compliant_strictest" {
  attrs = {
    load_balancer_type = "application"
    desync_mitigation_mode = "strictest"
    name = "test-alb-strictest"
  }
}

# Test 3: PASS - ALB without desync_mitigation_mode (defaults to defensive)
resource "aws_lb" "compliant_default" {
  attrs = {
    load_balancer_type = "application"
    name = "test-alb-default"
  }
}

# Test 4: FAIL - ALB with monitor mode
resource "aws_lb" "non_compliant_monitor" {
  expect_failure = true
  attrs = {
    load_balancer_type = "application"
    desync_mitigation_mode = "monitor"
    name = "test-alb-monitor"
  }
}

# Test 5: SKIP - Network Load Balancer (should not be evaluated due to filter)
resource "aws_lb" "network_lb" {
  attrs = {
    load_balancer_type = "gateway"
    desync_mitigation_mode = "monitor"
    name = "test-nlb"
  }
}
