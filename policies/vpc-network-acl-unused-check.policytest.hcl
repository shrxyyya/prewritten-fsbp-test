# Copyright IBM Corp. 2026

policytest {
  targets = ["vpc-network-acl-unused-check.policy.hcl"]
}

# Scenario 1: Network ACL with direct subnet associations via subnet_ids (PASS)
resource "aws_network_acl" "pass_direct_subnet_associations" {
  attrs = {
    vpc_id = "vpc-12345678"
    subnet_ids = ["subnet-11111111", "subnet-22222222"]
    tags = {
      Name = "test-nacl"
    }
  }
}

# Scenario 3: Unused network ACL with no subnet associations (FAIL)
resource "aws_network_acl" "fail_no_associations" {
  expect_failure = true
  attrs = {
    vpc_id = "vpc-12345678"
    subnet_ids = null
    tags = {
      Name = "unused-nacl"
    }
  }
}

# Scenario 4: Network ACL with empty subnet_ids list (FAIL)
resource "aws_network_acl" "fail_empty_subnet_ids" {
  expect_failure = true
  attrs = {
    vpc_id = "vpc-12345678"
    subnet_ids = []
    tags = {
      Name = "empty-nacl"
    }
  }
}

# Scenario 6: Default network ACL with no associations (PASS)
resource "aws_default_network_acl" "pass_default_no_associations" {
  attrs = {
    default_network_acl_id = "acl-default123"
    subnet_ids = null
    tags = {
      Name = "default-nacl"
    }
  }
}

# Scenario 7: Default network ACL with associations (PASS)
resource "aws_default_network_acl" "pass_default_with_associations" {
  attrs = {
    default_network_acl_id = "acl-default123"
    subnet_ids = ["subnet-11111111", "subnet-22222222"]
    tags = {
      Name = "default-nacl"
    }
  }
}

# Scenario 8: Network ACL with multiple subnet associations (PASS)
resource "aws_network_acl" "pass_multiple_subnets" {
  attrs = {
    vpc_id = "vpc-12345678"
    subnet_ids = ["subnet-11111111", "subnet-22222222", "subnet-33333333"]
    tags = {
      Name = "multi-subnet-nacl"
    }
  }
}

# Additional test: Network ACL with single subnet (PASS)
resource "aws_network_acl" "pass_single_subnet" {
  attrs = {
    vpc_id = "vpc-12345678"
    subnet_ids = ["subnet-11111111"]
    tags = {
      Name = "single-subnet-nacl"
    }
  }
}
