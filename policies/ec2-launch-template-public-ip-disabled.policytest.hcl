# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ec2-launch-template-public-ip-disabled.policy.hcl"
    ]
}

# Test 1: PASS - No network_interfaces block defined
resource "aws_launch_template" "pass_no_network_interfaces" {
  attrs = {
    name = "example-template"
    description = "Example launch template without network interfaces"
  }
}

# Test 2: PASS - associate_public_ip_address explicitly set to false
resource "aws_launch_template" "pass_explicit_false" {
  attrs = {
    name = "example-template"
    network_interfaces = [
      {
        associate_public_ip_address = false
        device_index = 0
        subnet_id = "subnet-12345678"
      }
    ]
  }
}

# Test 3: PASS - associate_public_ip_address not set (null)
resource "aws_launch_template" "pass_unset_attribute" {
  attrs = {
    name = "example-template"
    network_interfaces = [
      {
        device_index = 0
        subnet_id = "subnet-12345678"
        security_groups = ["sg-12345678"]
      }
    ]
  }
}

# Test 4: FAIL - associate_public_ip_address set to true
resource "aws_launch_template" "fail_public_ip_enabled" {
  expect_failure = true
  attrs = {
    name = "example-template"
    network_interfaces = [
      {
        associate_public_ip_address = true
        device_index = 0
        subnet_id = "subnet-12345678"
      }
    ]
  }
}

# Test 5: FAIL - Multiple interfaces with at least one having public IP enabled
resource "aws_launch_template" "fail_multiple_interfaces_one_public" {
  expect_failure = true
  attrs = {
    name = "example-template"
    network_interfaces = [
      {
        associate_public_ip_address = false
        device_index = 0
        subnet_id = "subnet-12345678"
      },
      {
        associate_public_ip_address = true
        device_index = 1
        subnet_id = "subnet-87654321"
      }
    ]
  }
}

# Test 6: PASS - Multiple interfaces all with public IP disabled
resource "aws_launch_template" "pass_multiple_interfaces_all_false" {
  attrs = {
    name = "example-template"
    network_interfaces = [
      {
        associate_public_ip_address = false
        device_index = 0
        subnet_id = "subnet-12345678"
      },
      {
        associate_public_ip_address = false
        device_index = 1
        subnet_id = "subnet-87654321"
      }
    ]
  }
}