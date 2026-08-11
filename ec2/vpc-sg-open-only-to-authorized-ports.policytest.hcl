# Copyright IBM Corp. 2026

policytest {
  targets = ["vpc-sg-open-only-to-authorized-ports.policy.hcl"]
}

# PASS: Security group with no ingress rules
resource "aws_security_group" "pass_no_ingress_rules" {
  attrs = {
    name        = "test-sg"
    description = "Test security group"
    vpc_id      = "vpc-12345678"
    ingress     = []
  }
}

# PASS: Security group allowing 0.0.0.0/0 on TCP port 80 (authorized)
resource "aws_security_group" "pass_port_80_ipv4" {
  attrs = {
    name        = "test-sg"
    description = "Test security group"
    vpc_id      = "vpc-12345678"
    ingress = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTP"
      }
    ]
  }
}

# PASS: Security group allowing 0.0.0.0/0 on TCP port 443 (authorized)
resource "aws_security_group" "pass_port_443_ipv4" {
  attrs = {
    name        = "test-sg"
    description = "Test security group"
    vpc_id      = "vpc-12345678"
    ingress = [
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTPS"
      }
    ]
  }
}

# PASS: Security group allowing ::/0 on TCP port 80 (authorized IPv6)
resource "aws_security_group" "pass_port_80_ipv6" {
  attrs = {
    name        = "test-sg"
    description = "Test security group"
    vpc_id      = "vpc-12345678"
    ingress = [
      {
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        ipv6_cidr_blocks = ["::/0"]
        description      = "Allow HTTP IPv6"
      }
    ]
  }
}

# PASS: Security group with restricted CIDR on port 22 (not 0.0.0.0/0)
resource "aws_security_group" "pass_restricted_cidr_ssh" {
  attrs = {
    name        = "test-sg"
    description = "Test security group"
    vpc_id      = "vpc-12345678"
    ingress = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/8"]
        description = "Allow SSH from internal network"
      }
    ]
  }
}

# FAIL: Security group allowing 0.0.0.0/0 on TCP port 22 (unauthorized)
resource "aws_security_group" "fail_port_22_ssh" {
  expect_failure = true
  attrs = {
    name        = "test-sg"
    description = "Test security group"
    vpc_id      = "vpc-12345678"
    ingress = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow SSH from anywhere"
      }
    ]
  }
}

# FAIL: Security group allowing 0.0.0.0/0 on TCP port 3389 (unauthorized)
resource "aws_security_group" "fail_port_3389_rdp" {
  expect_failure = true
  attrs = {
    name        = "test-sg"
    description = "Test security group"
    vpc_id      = "vpc-12345678"
    ingress = [
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow RDP from anywhere"
      }
    ]
  }
}

# FAIL: Security group allowing ::/0 on TCP port 22 (unauthorized IPv6)
resource "aws_security_group" "fail_port_22_ssh_ipv6" {
  expect_failure = true
  attrs = {
    name        = "test-sg"
    description = "Test security group"
    vpc_id      = "vpc-12345678"
    ingress = [
      {
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        ipv6_cidr_blocks = ["::/0"]
        description      = "Allow SSH from anywhere IPv6"
      }
    ]
  }
}

# FAIL: Security group allowing 0.0.0.0/0 on protocol -1 (all protocols)
resource "aws_security_group" "fail_all_protocols" {
  expect_failure = true
  attrs = {
    name        = "test-sg"
    description = "Test security group"
    vpc_id      = "vpc-12345678"
    ingress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all traffic"
      }
    ]
  }
}

# FAIL: Security group with multiple rules including unauthorized port
resource "aws_security_group" "fail_multiple_rules_with_violation" {
  expect_failure = true
  attrs = {
    name        = "test-sg"
    description = "Test security group"
    vpc_id      = "vpc-12345678"
    ingress = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTP"
      },
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow SSH"
      }
    ]
  }
}

# FAIL: Security group allowing 0.0.0.0/0 on UDP port 53 with no authorizedUdpPorts configured
resource "aws_security_group" "fail_udp_53_by_default" {
  expect_failure = true
  attrs = {
    name        = "test-sg"
    description = "Test security group"
    vpc_id      = "vpc-12345678"
    ingress = [
      {
        from_port   = 53
        to_port     = 53
        protocol    = "udp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow DNS from anywhere"
      }
    ]
  }
}

# ============================================================================
# Tests for aws_vpc_security_group_ingress_rule resource
# ============================================================================

# PASS: Ingress rule allowing 0.0.0.0/0 on TCP port 80 (authorized)
resource "aws_vpc_security_group_ingress_rule" "pass_ingress_rule_port_80" {
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 80
    to_port           = 80
    cidr_ipv4         = "0.0.0.0/0"
    description       = "Allow HTTP"
  }
}

# PASS: Ingress rule allowing 0.0.0.0/0 on TCP port 443 (authorized)
resource "aws_vpc_security_group_ingress_rule" "pass_ingress_rule_port_443" {
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 443
    to_port           = 443
    cidr_ipv4         = "0.0.0.0/0"
    description       = "Allow HTTPS"
  }
}

# PASS: Ingress rule allowing ::/0 on TCP port 443 (authorized IPv6)
resource "aws_vpc_security_group_ingress_rule" "pass_ingress_rule_port_443_ipv6" {
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 443
    to_port           = 443
    cidr_ipv6         = "::/0"
    description       = "Allow HTTPS IPv6"
  }
}

# PASS: Ingress rule with restricted CIDR on port 22 (not 0.0.0.0/0)
resource "aws_vpc_security_group_ingress_rule" "pass_ingress_rule_restricted_cidr" {
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 22
    to_port           = 22
    cidr_ipv4         = "192.168.1.0/24"
    description       = "Allow SSH from internal"
  }
}

# FAIL: Ingress rule allowing 0.0.0.0/0 on TCP port 22 (unauthorized)
resource "aws_vpc_security_group_ingress_rule" "fail_ingress_rule_port_22" {
  expect_failure = true
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 22
    to_port           = 22
    cidr_ipv4         = "0.0.0.0/0"
    description       = "Allow SSH from anywhere"
  }
}

# FAIL: Ingress rule allowing 0.0.0.0/0 on TCP port 3389 (unauthorized)
resource "aws_vpc_security_group_ingress_rule" "fail_ingress_rule_port_3389" {
  expect_failure = true
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 3389
    to_port           = 3389
    cidr_ipv4         = "0.0.0.0/0"
    description       = "Allow RDP from anywhere"
  }
}

# FAIL: Ingress rule allowing ::/0 on TCP port 3306 (unauthorized IPv6)
resource "aws_vpc_security_group_ingress_rule" "fail_ingress_rule_port_3306_ipv6" {
  expect_failure = true
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 3306
    to_port           = 3306
    cidr_ipv6         = "::/0"
    description       = "Allow MySQL from anywhere IPv6"
  }
}

# FAIL: Ingress rule allowing 0.0.0.0/0 on protocol -1 (all protocols)
resource "aws_vpc_security_group_ingress_rule" "fail_ingress_rule_all_protocols" {
  expect_failure = true
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "-1"
    cidr_ipv4         = "0.0.0.0/0"
    description       = "Allow all traffic"
  }
}

# FAIL: Ingress rule allowing 0.0.0.0/0 on UDP port 53 with no authorizedUdpPorts configured
resource "aws_vpc_security_group_ingress_rule" "fail_ingress_rule_udp_53_by_default" {
  expect_failure = true
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "udp"
    from_port         = 53
    to_port           = 53
    cidr_ipv4         = "0.0.0.0/0"
    description       = "Allow DNS from anywhere"
  }
}
