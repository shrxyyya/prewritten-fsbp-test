# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elbv2-targetgroup-protocol-encrypted.policy.hcl"
    ]
}

# Test 1: PASS - HTTPS protocol with instance target type
resource "aws_lb_target_group" "https_instance_pass" {
  attrs = {
    protocol    = "HTTPS"
    target_type = "instance"
  }
}

# Test 2: PASS - TLS protocol with IP target type
resource "aws_lb_target_group" "tls_ip_pass" {
  attrs = {
    protocol    = "TLS"
    target_type = "ip"
  }
}

# Test 3: PASS - QUIC protocol with instance target type
resource "aws_lb_target_group" "quic_instance_pass" {
  attrs = {
    protocol    = "QUIC"
    target_type = "instance"
  }
}

# Test 4: FAIL - HTTP protocol with instance target type
resource "aws_lb_target_group" "http_instance_fail" {
  expect_failure = true
  attrs = {
    protocol    = "HTTP"
    target_type = "instance"
  }
}

# Test 5: FAIL - TCP protocol with IP target type
resource "aws_lb_target_group" "tcp_ip_fail" {
  expect_failure = true
  attrs = {
    protocol    = "TCP"
    target_type = "ip"
  }
}

# Test 6: FAIL - UDP protocol with instance target type
resource "aws_lb_target_group" "udp_instance_fail" {
  expect_failure = true
  attrs = {
    protocol    = "UDP"
    target_type = "instance"
  }
}

# Test 7: PASS - GENEVE protocol with instance target type (excluded)
resource "aws_lb_target_group" "geneve_excluded_pass" {
  attrs = {
    protocol    = "GENEVE"
    target_type = "instance"
  }
}

# Test 8: PASS - Lambda target type (excluded) with any protocol
resource "aws_lb_target_group" "lambda_excluded_pass" {
  attrs = {
    protocol    = "HTTP"
    target_type = "lambda"
  }
}

# Test 9: PASS - ALB target type (excluded) with UDP protocol
resource "aws_lb_target_group" "alb_excluded_pass" {
  attrs = {
    protocol    = "UDP"
    target_type = "alb"
  }
}
