# Copyright IBM Corp. 2026

policytest {
  targets = [
    "alb-http-to-https-redirection-check.policy.hcl"
  ]
}

# Test 1: PASS - HTTP listener with proper redirect to HTTPS:443
resource "aws_lb_listener" "http_redirect" {
  attrs = {
    protocol          = "HTTP"
    port              = 80
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/1234567890abcdef"
    default_action = [
      {
        type = "redirect"
        redirect = {
          protocol    = "HTTPS"
          port        = "443"
          status_code = "HTTP_301"
        }
      }
    ]
  }
}

# Test 2: FAIL - HTTP listener without redirect action (forwards to target group)
resource "aws_lb_listener" "http_no_redirect" {
  expect_failure = true
  attrs = {
    protocol          = "HTTP"
    port              = 80
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/1234567890abcdef"
    default_action = [
      {
        type             = "forward"
        target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-targets/1234567890abcdef"
      }
    ]
  }
}

# Test 3: FAIL - HTTP listener with redirect to HTTP (not HTTPS)
resource "aws_lb_listener" "http_to_http" {
  expect_failure = true
  attrs = {
    protocol          = "HTTP"
    port              = 80
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/1234567890abcdef"
    default_action = [
      {
        type = "redirect"
        redirect = {
          protocol    = "HTTP"
          port        = "8080"
          status_code = "HTTP_301"
        }
      }
    ]
  }
}

# Test 4: PASS - HTTP listener with redirect to HTTPS on a non-standard port
# (the AWS Config rule requires HTTPS redirect, not specifically port 443)
resource "aws_lb_listener" "http_redirect_alt_port" {
  attrs = {
    protocol          = "HTTP"
    port              = 80
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/1234567890abcdef"
    default_action = [
      {
        type = "redirect"
        redirect = {
          protocol    = "HTTPS"
          port        = "8443"
          status_code = "HTTP_301"
        }
      }
    ]
  }
}

# Test 5: SKIP - HTTPS listener (not evaluated due to filter)
resource "aws_lb_listener" "https" {
  attrs = {
    protocol          = "HTTPS"
    port              = 443
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/1234567890abcdef"
    certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
    default_action = [
      {
        type             = "forward"
        target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-targets/1234567890abcdef"
      }
    ]
  }
}

# Test 6: FAIL - HTTP listener on a non-standard port without redirect
# (ELB.1 covers HTTP listeners regardless of port)
resource "aws_lb_listener" "http_8080_no_redirect" {
  expect_failure = true
  attrs = {
    protocol          = "HTTP"
    port              = 8080
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/1234567890abcdef"
    default_action = [
      {
        type             = "forward"
        target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-targets/1234567890abcdef"
      }
    ]
  }
}
