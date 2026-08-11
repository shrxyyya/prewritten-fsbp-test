# Copyright IBM Corp. 2026

policytest {
  targets = [
    "vpc-default-security-group-closed.policy.hcl"
    ]
}

# Test 1: PASS - Default security group with no rules
resource "aws_default_security_group" "pass_no_rules" {
  attrs = {
    id = "sg-12345678"
    vpc_id = "vpc-12345678"
    ingress = []
    egress = []
    tags = {
      Name = "default-sg"
    }
  }
}

# Test 2: PASS - Default security group with null ingress and egress
resource "aws_default_security_group" "pass_null_rules" {
  attrs = {
    id = "sg-23456789"
    vpc_id = "vpc-23456789"
    ingress = null
    egress = null
    tags = {
      Name = "default-sg-null"
    }
  }
}

# Test 3: FAIL - Default security group with inline ingress rules
resource "aws_default_security_group" "fail_inline_ingress" {
  expect_failure = true
  attrs = {
    id = "sg-34567890"
    vpc_id = "vpc-34567890"
    ingress = [
      {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/8"]
        description = "SSH from internal"
      }
    ]
    egress = []
    tags = {
      Name = "default-sg-ingress"
    }
  }
}

# Test 4: FAIL - Default security group with inline egress rules
resource "aws_default_security_group" "fail_inline_egress" {
  expect_failure = true
  attrs = {
    id = "sg-45678901"
    vpc_id = "vpc-45678901"
    ingress = []
    egress = [
      {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound"
      }
    ]
    tags = {
      Name = "default-sg-egress"
    }
  }
}

# Test 5: FAIL - Default security group with both inline ingress and egress rules
resource "aws_default_security_group" "fail_both_inline_rules" {
  expect_failure = true
  attrs = {
    id = "sg-56789012"
    vpc_id = "vpc-56789012"
    ingress = [
      {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTPS from anywhere"
      }
    ]
    egress = [
      {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound"
      }
    ]
    tags = {
      Name = "default-sg-both"
    }
  }
}

# Test 6: FAIL - Default security group with separate ingress rule resource
resource "aws_default_security_group" "fail_external_ingress" {
  expect_failure = true
  attrs = {
    id = "sg-67890123"
    vpc_id = "vpc-67890123"
    ingress = []
    egress = []
    tags = {
      Name = "default-sg-external-ingress"
    }
  }
}

resource "aws_vpc_security_group_ingress_rule" "external_ingress" {
  attrs = {
    security_group_id = "sg-67890123"
    ip_protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_ipv4 = "0.0.0.0/0"
    description = "HTTP from anywhere"
  }
}

# Test 7: FAIL - Default security group with separate egress rule resource
resource "aws_default_security_group" "fail_external_egress" {
  expect_failure = true
  attrs = {
    id = "sg-78901234"
    vpc_id = "vpc-78901234"
    ingress = []
    egress = []
    tags = {
      Name = "default-sg-external-egress"
    }
  }
}

resource "aws_vpc_security_group_egress_rule" "external_egress" {
  attrs = {
    security_group_id = "sg-78901234"
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"
    description = "Allow all outbound"
  }
}

# Test 8: FAIL - Default security group with legacy security group rule
resource "aws_default_security_group" "fail_legacy_rule" {
  expect_failure = true
  attrs = {
    id = "sg-89012345"
    vpc_id = "vpc-89012345"
    ingress = []
    egress = []
    tags = {
      Name = "default-sg-legacy"
    }
  }
}

resource "aws_security_group_rule" "legacy_rule" {
  attrs = {
    security_group_id = "sg-89012345"
    type = "ingress"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["10.0.0.0/8"]
    description = "SSH from internal"
  }
}

# Test 9: FAIL - Multiple violations (inline ingress + external egress)
resource "aws_default_security_group" "fail_multiple_violations" {
  expect_failure = true
  attrs = {
    id = "sg-90123456"
    vpc_id = "vpc-90123456"
    ingress = [
      {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH from anywhere"
      }
    ]
    egress = []
    tags = {
      Name = "default-sg-multiple"
    }
  }
}

resource "aws_vpc_security_group_egress_rule" "multiple_violation_egress" {
  attrs = {
    security_group_id = "sg-90123456"
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"
    description = "Allow all outbound"
  }
}