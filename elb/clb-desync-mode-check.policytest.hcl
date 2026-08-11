# Copyright IBM Corp. 2026

policytest {
  targets = [
    "clb-desync-mode-check.policy.hcl"
  ]
}
# Test 1: PASS - Defensive mode (explicitly set)
resource "aws_elb" "pass_defensive_mode" {
  attrs = {
    name                      = "test-elb-defensive"
    availability_zones        = ["us-east-1a", "us-east-1b"]
    desync_mitigation_mode    = "defensive"
    
    listener = [
      {
        instance_port     = 80
        instance_protocol = "HTTP"
        lb_port          = 80
        lb_protocol      = "HTTP"
      }
    ]
  }
}

# Test 2: PASS - Strictest mode
resource "aws_elb" "pass_strictest_mode" {
  attrs = {
    name                      = "test-elb-strictest"
    availability_zones        = ["us-east-1a", "us-east-1b"]
    desync_mitigation_mode    = "strictest"
    
    listener = [
      {
        instance_port     = 80
        instance_protocol = "HTTP"
        lb_port          = 80
        lb_protocol      = "HTTP"
      }
    ]
  }
}

# Test 3: PASS - Default mode (no desync_mitigation_mode specified, defaults to defensive)
resource "aws_elb" "pass_default_mode" {
  attrs = {
    name                      = "test-elb-default"
    availability_zones        = ["us-east-1a", "us-east-1b"]
    # desync_mitigation_mode not specified - defaults to "defensive"
    
    listener = [
      {
        instance_port     = 80
        instance_protocol = "HTTP"
        lb_port          = 80
        lb_protocol      = "HTTP"
      }
    ]
  }
}

# Test 4: FAIL - Monitor mode (not allowed)
resource "aws_elb" "fail_monitor_mode" {
  expect_failure = true
  
  attrs = {
    name                      = "test-elb-monitor"
    availability_zones        = ["us-east-1a", "us-east-1b"]
    desync_mitigation_mode    = "monitor"
    
    listener = [
      {
        instance_port     = 80
        instance_protocol = "HTTP"
        lb_port          = 80
        lb_protocol      = "HTTP"
      }
    ]
  }
}