# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ec2-nacl-no-unrestricted-ssh-rdp.policy.hcl"
    ]
}

# Test 1: PASS - aws_network_acl with restricted SSH access
resource "aws_network_acl" "pass_restricted_ssh" {
  attrs = {
    vpc_id = "vpc-12345678"
    ingress = [
      {
        protocol   = "tcp"
        rule_no    = 100
        action     = "allow"
        cidr_block = "10.0.0.0/8"
        from_port  = 22
        to_port    = 22
      }
    ]
  }
}

# Test 2: PASS - aws_network_acl with restricted RDP access
resource "aws_network_acl" "pass_restricted_rdp" {
  attrs = {
    vpc_id = "vpc-12345678"
    ingress = [
      {
        protocol   = "tcp"
        rule_no    = 100
        action     = "allow"
        cidr_block = "192.168.1.0/24"
        from_port  = 3389
        to_port    = 3389
      }
    ]
  }
}

# Test 3: FAIL - aws_network_acl allowing SSH from 0.0.0.0/0
resource "aws_network_acl" "fail_unrestricted_ssh_ipv4" {
  expect_failure = true
  attrs = {
    vpc_id = "vpc-12345678"
    ingress = [
      {
        protocol   = "tcp"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 22
        to_port    = 22
      }
    ]
  }
}

# Test 4: FAIL - aws_network_acl allowing RDP from 0.0.0.0/0
resource "aws_network_acl" "fail_unrestricted_rdp_ipv4" {
  expect_failure = true
  attrs = {
    vpc_id = "vpc-12345678"
    ingress = [
      {
        protocol   = "tcp"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 3389
        to_port    = 3389
      }
    ]
  }
}

# Test 5: FAIL - aws_network_acl allowing SSH from ::/0 (IPv6)
resource "aws_network_acl" "fail_unrestricted_ssh_ipv6" {
  expect_failure = true
  attrs = {
    vpc_id = "vpc-12345678"
    ingress = [
      {
        protocol         = "tcp"
        rule_no          = 100
        action           = "allow"
        ipv6_cidr_block  = "::/0"
        from_port        = 22
        to_port          = 22
      }
    ]
  }
}

# Test 6: FAIL - aws_network_acl allowing RDP from ::/0 (IPv6)
resource "aws_network_acl" "fail_unrestricted_rdp_ipv6" {
  expect_failure = true
  attrs = {
    vpc_id = "vpc-12345678"
    ingress = [
      {
        protocol         = "tcp"
        rule_no          = 100
        action           = "allow"
        ipv6_cidr_block  = "::/0"
        from_port        = 3389
        to_port          = 3389
      }
    ]
  }
}

# Test 7: PASS - aws_network_acl with deny rule for SSH from 0.0.0.0/0
resource "aws_network_acl" "pass_deny_ssh" {
  attrs = {
    vpc_id = "vpc-12345678"
    ingress = [
      {
        protocol   = "tcp"
        rule_no    = 100
        action     = "deny"
        cidr_block = "0.0.0.0/0"
        from_port  = 22
        to_port    = 22
      }
    ]
  }
}

# Test 8: FAIL - aws_network_acl allowing port range including SSH
resource "aws_network_acl" "fail_port_range_ssh" {
  expect_failure = true
  attrs = {
    vpc_id = "vpc-12345678"
    ingress = [
      {
        protocol   = "tcp"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 20
        to_port    = 25
      }
    ]
  }
}

# Test 9: FAIL - aws_network_acl allowing port range including RDP
resource "aws_network_acl" "fail_port_range_rdp" {
  expect_failure = true
  attrs = {
    vpc_id = "vpc-12345678"
    ingress = [
      {
        protocol   = "tcp"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 3380
        to_port    = 3400
      }
    ]
  }
}

# Test 10: PASS - aws_network_acl_rule with restricted SSH access
resource "aws_network_acl_rule" "pass_rule_restricted_ssh" {
  attrs = {
    network_acl_id = "acl-12345678"
    rule_number    = 100
    egress         = false
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = "10.0.0.0/8"
    from_port      = 22
    to_port        = 22
  }
}

# Test 11: FAIL - aws_network_acl_rule allowing SSH from 0.0.0.0/0
resource "aws_network_acl_rule" "fail_rule_unrestricted_ssh" {
  expect_failure = true
  attrs = {
    network_acl_id = "acl-12345678"
    rule_number    = 100
    egress         = false
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = "0.0.0.0/0"
    from_port      = 22
    to_port        = 22
  }
}

# Test 12: FAIL - aws_network_acl_rule allowing RDP from 0.0.0.0/0
resource "aws_network_acl_rule" "fail_rule_unrestricted_rdp" {
  expect_failure = true
  attrs = {
    network_acl_id = "acl-12345678"
    rule_number    = 100
    egress         = false
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = "0.0.0.0/0"
    from_port      = 3389
    to_port        = 3389
  }
}

# Test 13: PASS - aws_network_acl_rule with egress rule (not checked)
resource "aws_network_acl_rule" "pass_rule_egress" {
  attrs = {
    network_acl_id = "acl-12345678"
    rule_number    = 100
    egress         = true
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = "0.0.0.0/0"
    from_port      = 22
    to_port        = 22
  }
}

# Test 14: PASS - aws_network_acl with no ingress rules
resource "aws_network_acl" "pass_no_ingress" {
  attrs = {
    vpc_id = "vpc-12345678"
    ingress = []
  }
}

# Test 15: FAIL - aws_network_acl allowing SSH via UDP from 0.0.0.0/0
resource "aws_network_acl" "fail_unrestricted_ssh_udp" {
  expect_failure = true
  attrs = {
    vpc_id = "vpc-12345678"
    ingress = [
      {
        protocol   = "udp"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 22
        to_port    = 22
      }
    ]
  }
}

# Test 16: FAIL - aws_network_acl allowing RDP via UDP from 0.0.0.0/0
resource "aws_network_acl" "fail_unrestricted_rdp_udp" {
  expect_failure = true
  attrs = {
    vpc_id = "vpc-12345678"
    ingress = [
      {
        protocol   = "udp"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 3389
        to_port    = 3389
      }
    ]
  }
}

# Test 17: FAIL - aws_network_acl allowing SSH via all protocols from 0.0.0.0/0
resource "aws_network_acl" "fail_unrestricted_ssh_all_protocols" {
  expect_failure = true
  attrs = {
    vpc_id = "vpc-12345678"
    ingress = [
      {
        protocol   = "-1"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 22
        to_port    = 22
      }
    ]
  }
}

# Test 18: FAIL - aws_network_acl allowing RDP via all protocols from 0.0.0.0/0
resource "aws_network_acl" "fail_unrestricted_rdp_all_protocols" {
  expect_failure = true
  attrs = {
    vpc_id = "vpc-12345678"
    ingress = [
      {
        protocol   = "-1"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 3389
        to_port    = 3389
      }
    ]
  }
}

# Test 19: FAIL - aws_network_acl_rule allowing SSH via UDP from 0.0.0.0/0
resource "aws_network_acl_rule" "fail_rule_unrestricted_ssh_udp" {
  expect_failure = true
  attrs = {
    network_acl_id = "acl-12345678"
    rule_number    = 100
    egress         = false
    protocol       = "udp"
    rule_action    = "allow"
    cidr_block     = "0.0.0.0/0"
    from_port      = 22
    to_port        = 22
  }
}

# Test 20: FAIL - aws_network_acl_rule allowing RDP via UDP from 0.0.0.0/0
resource "aws_network_acl_rule" "fail_rule_unrestricted_rdp_udp" {
  expect_failure = true
  attrs = {
    network_acl_id = "acl-12345678"
    rule_number    = 100
    egress         = false
    protocol       = "udp"
    rule_action    = "allow"
    cidr_block     = "0.0.0.0/0"
    from_port      = 3389
    to_port        = 3389
  }
}

# Test 21: FAIL - aws_network_acl_rule allowing SSH from ::/0 (IPv6)
resource "aws_network_acl_rule" "fail_rule_unrestricted_ssh_ipv6" {
  expect_failure = true
  attrs = {
    network_acl_id  = "acl-12345678"
    rule_number     = 100
    egress          = false
    protocol        = "tcp"
    rule_action     = "allow"
    ipv6_cidr_block = "::/0"
    from_port       = 22
    to_port         = 22
  }
}

# Test 22: FAIL - aws_network_acl_rule allowing RDP from ::/0 (IPv6)
resource "aws_network_acl_rule" "fail_rule_unrestricted_rdp_ipv6" {
  expect_failure = true
  attrs = {
    network_acl_id  = "acl-12345678"
    rule_number     = 100
    egress          = false
    protocol        = "tcp"
    rule_action     = "allow"
    ipv6_cidr_block = "::/0"
    from_port       = 3389
    to_port         = 3389
  }
}

# Test 23: PASS - aws_network_acl_rule with deny action for SSH from 0.0.0.0/0
resource "aws_network_acl_rule" "pass_rule_deny_ssh" {
  attrs = {
    network_acl_id = "acl-12345678"
    rule_number    = 100
    egress         = false
    protocol       = "tcp"
    rule_action    = "deny"
    cidr_block     = "0.0.0.0/0"
    from_port      = 22
    to_port        = 22
  }
}

# Test 24: FAIL - aws_network_acl_rule allowing port range including SSH
resource "aws_network_acl_rule" "fail_rule_port_range_ssh" {
  expect_failure = true
  attrs = {
    network_acl_id = "acl-12345678"
    rule_number    = 100
    egress         = false
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = "0.0.0.0/0"
    from_port      = 20
    to_port        = 25
  }
}

# Test 25: FAIL - aws_network_acl_rule allowing port range including RDP
resource "aws_network_acl_rule" "fail_rule_port_range_rdp" {
  expect_failure = true
  attrs = {
    network_acl_id = "acl-12345678"
    rule_number    = 100
    egress         = false
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = "0.0.0.0/0"
    from_port      = 3380
    to_port        = 3400
  }
}
