# Copyright IBM Corp. 2026

policytest {
  targets = [
    "elbv2-multiple-az.policy.hcl"
  ]
  
}

inputs  {
    minAvailabilityZones = "1"
  }

# Fail Case: invalid minAvailabilityZones input (below valid range of 2)
resource "aws_lb" "lb_invalid_input" {
  expect_failure = true
  attrs = {
    arn                = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb-invalid/123"
    name               = "my-alb-invalid"
    load_balancer_type = "application"
  }
}

resource "aws_lb_listener" "lb_invalid_input" {
  attrs = {
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb-invalid/123"
    default_action = [{
      type             = "forward"
      target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/alb-invalid/123"
    }]
  }
}

resource "aws_lb_target_group_attachment" "alb_invalid_attachment_a" {
  attrs = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/alb-invalid/123"
    target_id        = "i-alb-az1"
  }
}

resource "aws_lb_target_group_attachment" "alb_invalid_attachment_b" {
  attrs = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/alb-invalid/123"
    target_id        = "i-alb-az2"
  }
}
