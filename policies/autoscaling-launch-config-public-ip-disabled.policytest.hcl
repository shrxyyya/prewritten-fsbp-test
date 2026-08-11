# Copyright IBM Corp. 2026

policytest {
  targets = [
    "autoscaling-launch-config-public-ip-disabled.policy.hcl"
  ]
}
# Test 1: Pass - associate_public_ip_address explicitly set to false
resource "aws_launch_configuration" "compliant_explicit" {
  attrs = {
    name                        = "compliant-lc-explicit"
    image_id                    = "ami-12345678"
    instance_type               = "t3.micro"
    associate_public_ip_address = false
  }
}

# Test 2: Pass - associate_public_ip_address omitted (defaults to false)
resource "aws_launch_configuration" "compliant_omitted" {
  attrs = {
    name          = "compliant-lc-omitted"
    image_id      = "ami-12345678"
    instance_type = "t3.micro"
  }
}

# Test 3: Fail - associate_public_ip_address set to true
resource "aws_launch_configuration" "non_compliant" {
  expect_failure = true
  attrs = {
    name                        = "non-compliant-lc"
    image_id                    = "ami-12345678"
    instance_type               = "t3.micro"
    associate_public_ip_address = true
  }
}
