# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ec2-paravirtual-instance-check.policy.hcl"
  ]
}

# Test 1: PASS - EC2 instance using HVM virtualization type
resource "aws_ami" "hvm_ami" {
  attrs = {
    id                  = "ami-12345678"
    virtualization_type = "hvm"
  }
}

resource "aws_instance" "hvm_instance" {
  attrs = {
    ami           = "ami-12345678"
    instance_type = "t3.micro"
  }
}

# Test 2: FAIL - EC2 instance using paravirtual virtualization type
resource "aws_ami" "paravirtual_ami" {
  attrs = {
    id                  = "ami-87654321"
    virtualization_type = "paravirtual"
  }
}

resource "aws_instance" "paravirtual_instance" {
  expect_failure = true
  attrs = {
    ami           = "ami-87654321"
    instance_type = "t2.micro"
  }
}

# Test 3: PASS - EC2 instance whose AMI cannot be resolved in this Terraform config
# is skipped (policy assumes compliant when AMI is from a data source / external state)
resource "aws_instance" "unknown_ami_instance" {
  attrs = {
    ami           = "ami-notfound"
    instance_type = "t3.small"
  }
}

# Test 4: PASS - Another HVM instance to verify multiple instances work
resource "aws_ami" "hvm_ami_2" {
  attrs = {
    id                  = "ami-11111111"
    virtualization_type = "hvm"
  }
}

resource "aws_instance" "hvm_instance_2" {
  attrs = {
    ami           = "ami-11111111"
    instance_type = "t3.large"
  }
}
