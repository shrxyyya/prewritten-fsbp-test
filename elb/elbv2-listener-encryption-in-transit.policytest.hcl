# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elbv2-listener-encryption-in-transit.policy.hcl"
    ]
}

# Test 1: PASS - Application Load Balancer listener with HTTPS protocol
resource "aws_lb_listener" "alb_https_pass" {
  attrs = {
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/50dc6c495c0c9188"
    port = 443
    protocol = "HTTPS"
    ssl_policy = "ELBSecurityPolicy-2016-08"
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  }
}

resource "aws_lb" "alb_https_pass" {
  skip = true
  attrs = {
    arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/50dc6c495c0c9188"
    name = "my-alb"
    load_balancer_type = "application"
    internal = false
  }
}

# Test 2: FAIL - Application Load Balancer listener with HTTP protocol
resource "aws_lb_listener" "alb_http_fail" {
  expect_failure = true
  attrs = {
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb-http/50dc6c495c0c9189"
    port = 80
    protocol = "HTTP"
  }
}

resource "aws_lb" "alb_http_fail" {
  skip = true
  attrs = {
    arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb-http/50dc6c495c0c9189"
    name = "my-alb-http"
    load_balancer_type = "application"
    internal = false
  }
}

# Test 3: PASS - Network Load Balancer listener with TLS protocol
resource "aws_lb_listener" "nlb_tls_pass" {
  attrs = {
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/net/my-nlb/50dc6c495c0c9190"
    port = 443
    protocol = "TLS"
    ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  }
}

resource "aws_lb" "nlb_tls_pass" {
  skip = true
  attrs = {
    arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/net/my-nlb/50dc6c495c0c9190"
    name = "my-nlb"
    load_balancer_type = "network"
    internal = false
  }
}

# Test 4: FAIL - Network Load Balancer listener with TCP protocol
resource "aws_lb_listener" "nlb_tcp_fail" {
  expect_failure = true
  attrs = {
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/net/my-nlb-tcp/50dc6c495c0c9191"
    port = 80
    protocol = "TCP"
  }
}

resource "aws_lb" "nlb_tcp_fail" {
  skip = true
  attrs = {
    arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/net/my-nlb-tcp/50dc6c495c0c9191"
    name = "my-nlb-tcp"
    load_balancer_type = "network"
    internal = false
  }
}

# Test 5: FAIL - Network Load Balancer listener with UDP protocol
resource "aws_lb_listener" "nlb_udp_fail" {
  expect_failure = true
  attrs = {
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/net/my-nlb-udp/50dc6c495c0c9192"
    port = 53
    protocol = "UDP"
  }
}

resource "aws_lb" "nlb_udp_fail" {
  skip = true
  attrs = {
    arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/net/my-nlb-udp/50dc6c495c0c9192"
    name = "my-nlb-udp"
    load_balancer_type = "network"
    internal = false
  }
}

# Test 6: FAIL - Application Load Balancer listener with TLS protocol (wrong protocol for ALB)
resource "aws_lb_listener" "alb_tls_fail" {
  expect_failure = true
  attrs = {
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb-tls/50dc6c495c0c9193"
    port = 443
    protocol = "TLS"
    ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  }
}

resource "aws_lb" "alb_tls_fail" {
  skip = true
  attrs = {
    arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb-tls/50dc6c495c0c9193"
    name = "my-alb-tls"
    load_balancer_type = "application"
    internal = false
  }
}
