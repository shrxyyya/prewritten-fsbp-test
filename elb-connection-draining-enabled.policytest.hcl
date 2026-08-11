# Copyright IBM Corp. 2026

policytest {
  targets = ["elb-connection-draining-enabled.policy.hcl"]
}

# Test 1: PASS - Connection draining explicitly enabled
resource "aws_elb" "compliant" {
  attrs = {
    name                        = "compliant-elb"
    availability_zones          = ["us-east-1a", "us-east-1b"]
    connection_draining         = true
    connection_draining_timeout = 300
    listener = [
      {
        instance_port     = 80
        instance_protocol = "HTTP"
        lb_port           = 80
        lb_protocol       = "HTTP"
      }
    ]
  }
}

# Test 2: FAIL - Connection draining explicitly disabled
resource "aws_elb" "non_compliant_disabled" {
  expect_failure = true
  attrs = {
    name                        = "non-compliant-elb"
    availability_zones          = ["us-east-1a", "us-east-1b"]
    connection_draining         = false
    listener = [
      {
        instance_port     = 80
        instance_protocol = "HTTP"
        lb_port           = 80
        lb_protocol       = "HTTP"
      }
    ]
  }
}

# Test 3: FAIL - Connection draining not specified (defaults to false)
resource "aws_elb" "non_compliant_default" {
  expect_failure = true
  attrs = {
    name               = "default-elb"
    availability_zones = ["us-east-1a", "us-east-1b"]
    listener = [
      {
        instance_port     = 80
        instance_protocol = "HTTP"
        lb_port           = 80
        lb_protocol       = "HTTP"
      }
    ]
    # connection_draining not specified - defaults to false
  }
}
