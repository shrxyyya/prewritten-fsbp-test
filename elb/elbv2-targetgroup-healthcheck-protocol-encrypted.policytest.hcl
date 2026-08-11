# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elbv2-targetgroup-healthcheck-protocol-encrypted.policy.hcl"
    ]
}

# Test 1: PASS - ALB target group with HTTPS health check protocol
resource "aws_lb_target_group" "alb_https" {
  attrs = {
    name        = "alb-target-group-https"
    target_type = "instance"
    protocol    = "HTTP"
    port        = 80
    vpc_id      = "vpc-12345678"
    health_check = [
      {
        enabled             = true
        protocol            = "HTTPS"
        path                = "/health"
        port                = "443"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        matcher             = "200"
      }
    ]
  }
}

# Test 2: PASS - NLB target group with HTTPS health check protocol
resource "aws_lb_target_group" "nlb_https" {
  attrs = {
    name        = "nlb-target-group-https"
    target_type = "ip"
    protocol    = "TCP"
    port        = 443
    vpc_id      = "vpc-12345678"
    health_check = [
      {
        enabled             = true
        protocol            = "HTTPS"
        port                = "443"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 10
        interval            = 30
      }
    ]
  }
}

# Test 3: FAIL - Target group with HTTP health check protocol
resource "aws_lb_target_group" "http" {
  expect_failure = true
  attrs = {
    name        = "target-group-http"
    target_type = "instance"
    protocol    = "HTTP"
    port        = 80
    vpc_id      = "vpc-12345678"
    health_check = [
      {
        enabled             = true
        protocol            = "HTTP"
        path                = "/health"
        port                = "80"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        matcher             = "200"
      }
    ]
  }
}

# Test 4: FAIL - Target group with TCP health check protocol
resource "aws_lb_target_group" "tcp" {
  expect_failure = true
  attrs = {
    name        = "target-group-tcp"
    target_type = "ip"
    protocol    = "TCP"
    port        = 80
    vpc_id      = "vpc-12345678"
    health_check = [
      {
        enabled             = true
        protocol            = "TCP"
        port                = "80"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 10
        interval            = 30
      }
    ]
  }
}

# Test 5: FAIL - Target group without health_check block
resource "aws_lb_target_group" "no_health_check" {
  expect_failure = true
  attrs = {
    name        = "target-group-no-hc"
    target_type = "instance"
    protocol    = "HTTP"
    port        = 80
    vpc_id      = "vpc-12345678"
  }
}

# Test 6: FAIL - Target group with empty health_check list
resource "aws_lb_target_group" "empty_hc" {
  expect_failure = true
  attrs = {
    name        = "target-group-empty-hc"
    target_type = "instance"
    protocol    = "HTTP"
    port        = 80
    vpc_id      = "vpc-12345678"
    health_check = []
  }
}

# Test 7: PASS - Lambda target group (policy filter excludes lambda targets)
resource "aws_lb_target_group" "lambda" {
  attrs = {
    name        = "lambda-target-group"
    target_type = "lambda"
    vpc_id      = "vpc-12345678"
    health_check = [
      {
        enabled             = true
        protocol            = "HTTP"
        path                = "/health"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        matcher             = "200"
      }
    ]
  }
}
