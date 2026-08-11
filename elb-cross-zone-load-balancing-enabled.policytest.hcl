# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elb-cross-zone-load-balancing-enabled.policy.hcl"
    ]
}

# Test 1: PASS - ELB with cross_zone_load_balancing explicitly set to true
resource "aws_elb" "explicit_true" {
  attrs = {
    name = "example-elb"
    cross_zone_load_balancing = true
    availability_zones = ["us-east-1a", "us-east-1b"]
    listener = [
      {
        instance_port = 80
        instance_protocol = "HTTP"
        lb_port = 80
        lb_protocol = "HTTP"
      }
    ]
  }
}

# Test 2: PASS - ELB without explicit cross_zone_load_balancing (defaults to true)
resource "aws_elb" "default_value" {
  attrs = {
    name = "default-elb"
    availability_zones = ["us-west-2a", "us-west-2b"]
    listener = [
      {
        instance_port = 443
        instance_protocol = "HTTPS"
        lb_port = 443
        lb_protocol = "HTTPS"
      }
    ]
  }
}

# Test 3: FAIL - ELB with cross_zone_load_balancing explicitly set to false
resource "aws_elb" "explicit_false" {
  expect_failure = true
  attrs = {
    name = "noncompliant-elb"
    cross_zone_load_balancing = false
    availability_zones = ["eu-west-1a", "eu-west-1b"]
    listener = [
      {
        instance_port = 8080
        instance_protocol = "HTTP"
        lb_port = 80
        lb_protocol = "HTTP"
      }
    ]
  }
}
