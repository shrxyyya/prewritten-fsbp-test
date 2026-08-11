# Copyright IBM Corp. 2026

policytest {
  targets = [
    "subnet-auto-assign-public-ip-disabled.policy.hcl"
  ]
}
# Test 1: Pass - Both attributes explicitly set to false
resource "aws_subnet" "pass_both_false" {
  attrs = {
    vpc_id                          = "vpc-12345678"
    cidr_block                      = "10.0.1.0/24"
    availability_zone               = "us-east-1a"
    map_public_ip_on_launch         = false
    assign_ipv6_address_on_creation = false
  }
}

# Test 2: Pass - Neither attribute set (relying on defaults)
resource "aws_subnet" "pass_defaults" {
  attrs = {
    vpc_id            = "vpc-12345678"
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-east-1b"
  }
}

# Test 3: Fail - map_public_ip_on_launch set to true
resource "aws_subnet" "fail_ipv4_auto_assign" {
  expect_failure = true
  attrs = {
    vpc_id                          = "vpc-12345678"
    cidr_block                      = "10.0.3.0/24"
    availability_zone               = "us-east-1c"
    map_public_ip_on_launch         = true
    assign_ipv6_address_on_creation = false
  }
}

# Test 4: Fail - assign_ipv6_address_on_creation set to true
resource "aws_subnet" "fail_ipv6_auto_assign" {
  expect_failure = true
  attrs = {
    vpc_id                          = "vpc-12345678"
    cidr_block                      = "10.0.4.0/24"
    ipv6_cidr_block                 = "2001:db8::/64"
    availability_zone               = "us-east-1d"
    map_public_ip_on_launch         = false
    assign_ipv6_address_on_creation = true
  }
}

# Test 5: Fail - Both attributes set to true
resource "aws_subnet" "fail_both_true" {
  expect_failure = true
  attrs = {
    vpc_id                          = "vpc-12345678"
    cidr_block                      = "10.0.5.0/24"
    ipv6_cidr_block                 = "2001:db8:1::/64"
    availability_zone               = "us-east-1e"
    map_public_ip_on_launch         = true
    assign_ipv6_address_on_creation = true
  }
}