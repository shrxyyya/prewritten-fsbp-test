# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ec2-stopped-instance-days-check.policy.hcl"
  ]
}

inputs {
    AllowedDays = 366
}

# FAIL - AllowedDays input outside 1-365 range
resource "aws_instance" "invalid_allowed_days_input" {
  expect_failure = true
  attrs = {
    instance_state = "running"
    instance_type  = "t2.micro"
    ami            = "ami-12345678"
    tags = {
      Name = "invalid-input-instance"
    }
  }
}
