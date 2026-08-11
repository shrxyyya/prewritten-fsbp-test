# Copyright IBM Corp. 2026

policytest {
    targets = [
        "clb-multiple-az.policy.hcl"
    ]
}

# Test 1: PASS - EC2-classic ELB with 2 availability zones (minimum required)
resource "aws_elb" "pass_ec2_classic_2_azs" {
  attrs = {
    availability_zones = ["us-east-1a", "us-east-1b"]
    subnets = null
  }
}

# Test 2: PASS - EC2-classic ELB with 3 availability zones (exceeds minimum)
resource "aws_elb" "pass_ec2_classic_3_azs" {
  attrs = {
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
    subnets = null
  }
}

# Test 3: FAIL - EC2-classic ELB with only 1 availability zone
resource "aws_elb" "fail_ec2_classic_1_az" {
  expect_failure = true
  attrs = {
    availability_zones = ["us-east-1a"]
    subnets = null
  }
}

# Test 4: PASS - VPC ELB with 2 subnets (minimum required)
resource "aws_elb" "pass_vpc_2_subnets" {
  attrs = {
    availability_zones = null
    subnets = ["subnet-12345678", "subnet-87654321"]
  }
}

# Test 5: PASS - VPC ELB with 3 subnets (exceeds minimum)
resource "aws_elb" "pass_vpc_3_subnets" {
  attrs = {
    availability_zones = null
    subnets = ["subnet-12345678", "subnet-87654321", "subnet-abcdef12"]
  }
}

# Test 6: FAIL - VPC ELB with only 1 subnet
resource "aws_elb" "fail_vpc_1_subnet" {
  expect_failure = true
  attrs = {
    availability_zones = null
    subnets = ["subnet-12345678"]
  }
}
