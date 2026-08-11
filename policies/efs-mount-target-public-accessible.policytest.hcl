# Copyright IBM Corp. 2026

policytest {
  targets = [
    "efs-mount-target-public-accessible.policy.hcl"
  ]
}
# Test 1: Pass - Mount target in subnet with map_public_ip_on_launch = false
resource "aws_subnet" "private" {
  attrs = {
    id                              = "subnet-private123"
    vpc_id                          = "vpc-12345678"
    cidr_block                      = "10.0.1.0/24"
    map_public_ip_on_launch         = false
    assign_ipv6_address_on_creation = false
  }
}

resource "aws_efs_mount_target" "pass_private_subnet" {
  attrs = {
    file_system_id = "fs-12345678"
    subnet_id      = "subnet-private123"
  }
}

# Test 2: Fail - Mount target in subnet with map_public_ip_on_launch = true
resource "aws_subnet" "public" {
  attrs = {
    id                              = "subnet-public123"
    vpc_id                          = "vpc-12345678"
    cidr_block                      = "10.0.2.0/24"
    map_public_ip_on_launch         = true
    assign_ipv6_address_on_creation = false
  }
}

resource "aws_efs_mount_target" "fail_public_subnet" {
  expect_failure = true
  attrs = {
    file_system_id = "fs-12345678"
    subnet_id      = "subnet-public123"
  }
}

# Test 3: Pass - IPv6 auto-assignment alone does not fail EFS.6 (spec is IPv4-only)
resource "aws_subnet" "ipv6" {
  attrs = {
    id                              = "subnet-ipv6-123"
    vpc_id                          = "vpc-12345678"
    cidr_block                      = "10.0.3.0/24"
    map_public_ip_on_launch         = false
    assign_ipv6_address_on_creation = true
  }
}

resource "aws_efs_mount_target" "pass_ipv6_subnet" {
  attrs = {
    file_system_id = "fs-12345678"
    subnet_id      = "subnet-ipv6-123"
  }
}

# Test 4: Pass - Mount target references a subnet not declared in the plan; cannot evaluate, treated as compliant
resource "aws_efs_mount_target" "pass_unknown_subnet" {
  attrs = {
    file_system_id = "fs-12345678"
    subnet_id      = "subnet-not-in-plan"
  }
}