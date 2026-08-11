# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elb-deletion-protection-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Application Load Balancer with deletion protection enabled
resource "aws_lb" "alb_protected" {
  attrs = {
    name                       = "my-alb"
    load_balancer_type         = "application"
    enable_deletion_protection = true
    internal                   = false
    subnets                    = ["subnet-12345", "subnet-67890"]
  }
}

# Test 2: PASS - Network Load Balancer with deletion protection enabled
resource "aws_lb" "nlb_protected" {
  attrs = {
    name                       = "my-nlb"
    load_balancer_type         = "network"
    enable_deletion_protection = true
    internal                   = false
    subnets                    = ["subnet-12345", "subnet-67890"]
  }
}

# Test 3: PASS - Gateway Load Balancer with deletion protection enabled
resource "aws_lb" "gwlb_protected" {
  attrs = {
    name                       = "my-gwlb"
    load_balancer_type         = "gateway"
    enable_deletion_protection = true
    internal                   = false
    subnets                    = ["subnet-12345", "subnet-67890"]
  }
}

# Test 4: FAIL - Application Load Balancer with deletion protection explicitly disabled
resource "aws_lb" "alb_unprotected" {
  expect_failure = true
  attrs = {
    name                       = "my-alb-unprotected"
    load_balancer_type         = "application"
    enable_deletion_protection = false
    internal                   = false
    subnets                    = ["subnet-12345", "subnet-67890"]
  }
}

# Test 5: FAIL - Network Load Balancer with deletion protection explicitly disabled
resource "aws_lb" "nlb_unprotected" {
  expect_failure = true
  attrs = {
    name                       = "my-nlb-unprotected"
    load_balancer_type         = "network"
    enable_deletion_protection = false
    internal                   = false
    subnets                    = ["subnet-12345", "subnet-67890"]
  }
}

# Test 6: FAIL - Gateway Load Balancer with deletion protection explicitly disabled
resource "aws_lb" "gwlb_unprotected" {
  expect_failure = true
  attrs = {
    name                       = "my-gwlb-unprotected"
    load_balancer_type         = "gateway"
    enable_deletion_protection = false
    internal                   = false
    subnets                    = ["subnet-12345", "subnet-67890"]
  }
}

# Test 7: FAIL - Application Load Balancer without deletion protection attribute (defaults to false)
resource "aws_lb" "alb_default" {
  expect_failure = true
  attrs = {
    name               = "my-alb-default"
    load_balancer_type = "application"
    internal           = false
    subnets            = ["subnet-12345", "subnet-67890"]
  }
}
