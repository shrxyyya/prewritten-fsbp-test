# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elb-logging-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Classic Load Balancer with access_logs.enabled = true
resource "aws_elb" "pass_with_enabled_true" {
  attrs = {
    name = "test-elb"
    access_logs = [
      {
        bucket = "my-logs-bucket"
        enabled = true
        interval = 60
      }
    ]
  }
}

# Test 2: PASS - Classic Load Balancer with access_logs block (enabled defaults to true)
resource "aws_elb" "pass_with_enabled_default" {
  attrs = {
    name = "test-elb-default"
    access_logs = [
      {
        bucket = "my-logs-bucket"
        interval = 60
      }
    ]
  }
}

# Test 3: FAIL - Classic Load Balancer with access_logs.enabled = false
resource "aws_elb" "fail_with_enabled_false" {
  expect_failure = true
  attrs = {
    name = "test-elb-disabled"
    access_logs = [
      {
        bucket = "my-logs-bucket"
        enabled = false
        interval = 60
      }
    ]
  }
}

# Test 4: FAIL - Classic Load Balancer without access_logs block
resource "aws_elb" "fail_without_access_logs" {
  expect_failure = true
  attrs = {
    name = "test-elb-no-logs"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }
}

# Test 5: FAIL - Classic Load Balancer with null access_logs
resource "aws_elb" "fail_with_null_access_logs" {
  expect_failure = true
  attrs = {
    name = "test-elb-null"
    access_logs = null
  }
}

# Test 6: PASS - Application Load Balancer with access_logs.enabled = true
resource "aws_lb" "pass_application_lb_with_enabled_true" {
  attrs = {
    name = "test-alb"
    load_balancer_type = "application"
    access_logs = [
      {
        bucket = "my-logs-bucket"
        enabled = true
        prefix = "alb-logs"
      }
    ]
  }
}

# Test 7: FAIL - Application Load Balancer with access_logs.enabled = false
resource "aws_lb" "fail_application_lb_with_enabled_false" {
  expect_failure = true
  attrs = {
    name = "test-alb-disabled"
    load_balancer_type = "application"
    access_logs = [
      {
        bucket = "my-logs-bucket"
        enabled = false
        prefix = "alb-logs"
      }
    ]
  }
}

# Test 8: FAIL - Application Load Balancer without access_logs block
resource "aws_lb" "fail_application_lb_without_access_logs" {
  expect_failure = true
  attrs = {
    name = "test-alb-no-logs"
    load_balancer_type = "application"
    subnets = ["subnet-12345", "subnet-67890"]
  }
}

# Test 9: FAIL - Application Load Balancer with bucket but enabled not specified (defaults to false)
resource "aws_lb" "fail_application_lb_with_bucket_but_no_enabled" {
  expect_failure = true
  attrs = {
    name = "test-alb-bucket-only"
    load_balancer_type = "application"
    access_logs = [
      {
        bucket = "my-logs-bucket"
        prefix = "alb-logs"
      }
    ]
  }
}

# Test 10: SKIP - Network Load Balancer (filtered out, not evaluated)
resource "aws_lb" "skip_network_load_balancer" {
  attrs = {
    name = "test-nlb"
    load_balancer_type = "network"
    subnets = ["subnet-12345", "subnet-67890"]
  }
}

# Test 11: PASS - Load Balancer with default type (application) and logging enabled
resource "aws_lb" "pass_application_lb_default_type" {
  attrs = {
    name = "test-alb-default"
    access_logs = [
      {
        bucket = "my-logs-bucket"
        enabled = true
      }
    ]
  }
}
