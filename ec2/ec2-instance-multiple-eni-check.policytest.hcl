# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ec2-instance-multiple-eni-check.policy.hcl"
  ]
}

# Test 1: PASS - Instance with only primary network interface
resource "aws_instance" "single_eni_pass" {
  attrs = {
    id = "i-single-eni"
    instance_type = "t2.micro"
    ami = "ami-12345678"
  }
}

# Test 2: FAIL - Instance with secondary_network_interface block
resource "aws_instance" "secondary_eni_fail" {
  expect_failure = true
  attrs = {
    id = "i-secondary-eni"
    instance_type = "t2.micro"
    ami = "ami-12345678"
    secondary_network_interface = [
      {
        device_index = 1
        network_interface_id = "eni-secondary-123"
        delete_on_termination = true
      }
    ]
  }
}

# Test 3: FAIL - Instance with deprecated network_interface block
resource "aws_instance" "deprecated_eni_fail" {
  expect_failure = true
  attrs = {
    id = "i-deprecated-eni"
    instance_type = "t2.micro"
    ami = "ami-12345678"
    network_interface = [
      {
        device_index = 1
        network_interface_id = "eni-deprecated-123"
        delete_on_termination = true
      }
    ]
  }
}

# Test 4: FAIL - Instance with separate ENI attachment
# Create a network interface attachment that references the instance
resource "aws_network_interface_attachment" "separate_attachment" {
  skip = true
  attrs = {
    instance_id = "i-separate-attachment"
    network_interface_id = "eni-separate-123"
    device_index = 1
  }
}

resource "aws_instance" "separate_attachment_fail" {
  expect_failure = true
  attrs = {
    id = "i-separate-attachment"
    instance_type = "t2.micro"
    ami = "ami-12345678"
  }
}

# Test 5: FAIL - Instance with multiple secondary_network_interface blocks
resource "aws_instance" "multiple_secondary_fail" {
  expect_failure = true
  attrs = {
    id = "i-multiple-secondary"
    instance_type = "t2.micro"
    ami = "ami-12345678"
    secondary_network_interface = [
      {
        device_index = 1
        network_interface_id = "eni-secondary-1"
        delete_on_termination = true
      },
      {
        device_index = 2
        network_interface_id = "eni-secondary-2"
        delete_on_termination = true
      }
    ]
  }
}

# Test 6: FAIL - Instance with both secondary_network_interface and separate attachment
resource "aws_network_interface_attachment" "combined_attachment" {
  skip = true
  attrs = {
    instance_id = "i-combined"
    network_interface_id = "eni-combined-123"
    device_index = 2
  }
}

resource "aws_instance" "combined_fail" {
  expect_failure = true
  attrs = {
    id = "i-combined"
    instance_type = "t2.micro"
    ami = "ami-12345678"
    secondary_network_interface = [
      {
        device_index = 1
        network_interface_id = "eni-combined-secondary"
        delete_on_termination = true
      }
    ]
  }
}
