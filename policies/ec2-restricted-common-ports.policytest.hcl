# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ec2-restricted-common-ports.policy.hcl"
    ]
}

# Test 1: FAIL - Standalone ingress rule allowing SSH (port 22) from 0.0.0.0/0
resource "aws_vpc_security_group_ingress_rule" "ssh_unrestricted" {
  expect_failure = true
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 22
    to_port           = 22
    cidr_ipv4         = "0.0.0.0/0"
  }
}

# Test 2: FAIL - Standalone ingress rule allowing RDP (port 3389) from 0.0.0.0/0
resource "aws_vpc_security_group_ingress_rule" "rdp_unrestricted" {
  expect_failure = true
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 3389
    to_port           = 3389
    cidr_ipv4         = "0.0.0.0/0"
  }
}

# Test 3: FAIL - Standalone ingress rule allowing MySQL (port 3306) from 0.0.0.0/0
resource "aws_vpc_security_group_ingress_rule" "mysql_unrestricted" {
  expect_failure = true
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 3306
    to_port           = 3306
    cidr_ipv4         = "0.0.0.0/0"
  }
}

# Test 4: FAIL - Standalone ingress rule allowing PostgreSQL (port 5432) from ::/0
resource "aws_vpc_security_group_ingress_rule" "postgresql_unrestricted_ipv6" {
  expect_failure = true
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 5432
    to_port           = 5432
    cidr_ipv6         = "::/0"
  }
}

# Test 5: FAIL - Standalone ingress rule allowing FTP (ports 20-21) from 0.0.0.0/0
resource "aws_vpc_security_group_ingress_rule" "ftp_unrestricted" {
  expect_failure = true
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 20
    to_port           = 21
    cidr_ipv4         = "0.0.0.0/0"
  }
}

# Test 6: FAIL - Standalone ingress rule allowing MSSQL (ports 1433-1434) from ::/0
resource "aws_vpc_security_group_ingress_rule" "mssql_unrestricted_ipv6" {
  expect_failure = true
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 1433
    to_port           = 1434
    cidr_ipv6         = "::/0"
  }
}

# Test 7: FAIL - Standalone ingress rule allowing OpenSearch (ports 9200-9300) from 0.0.0.0/0
resource "aws_vpc_security_group_ingress_rule" "opensearch_unrestricted" {
  expect_failure = true
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 9200
    to_port           = 9300
    cidr_ipv4         = "0.0.0.0/0"
  }
}

# Test 8: FAIL - Standalone ingress rule with all protocols from 0.0.0.0/0
resource "aws_vpc_security_group_ingress_rule" "all_protocols_unrestricted" {
  expect_failure = true
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "-1"
    cidr_ipv4         = "0.0.0.0/0"
  }
}

# Test 9: FAIL - Standalone ingress rule allowing multiple high-risk ports (20-25) from 0.0.0.0/0
resource "aws_vpc_security_group_ingress_rule" "multiple_high_risk_ports" {
  expect_failure = true
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 20
    to_port           = 25
    cidr_ipv4         = "0.0.0.0/0"
  }
}

# Test 10: PASS - Standalone ingress rule allowing HTTP (port 80) from 0.0.0.0/0
resource "aws_vpc_security_group_ingress_rule" "http_unrestricted" {
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 80
    to_port           = 80
    cidr_ipv4         = "0.0.0.0/0"
  }
}

# Test 11: PASS - Standalone ingress rule allowing HTTPS (port 443) from 0.0.0.0/0
resource "aws_vpc_security_group_ingress_rule" "https_unrestricted" {
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 443
    to_port           = 443
    cidr_ipv4         = "0.0.0.0/0"
  }
}

# Test 12: PASS - Standalone ingress rule allowing SSH (port 22) from specific CIDR
resource "aws_vpc_security_group_ingress_rule" "ssh_restricted" {
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 22
    to_port           = 22
    cidr_ipv4         = "192.168.1.0/24"
  }
}

# Test 13: PASS - Standalone ingress rule allowing RDP (port 3389) from specific IPv6 CIDR
resource "aws_vpc_security_group_ingress_rule" "rdp_restricted_ipv6" {
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 3389
    to_port           = 3389
    cidr_ipv6         = "2001:db8::/32"
  }
}

# Test 14: PASS - Standalone ingress rule allowing high-risk port range from specific CIDR
resource "aws_vpc_security_group_ingress_rule" "high_risk_range_restricted" {
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 20
    to_port           = 25
    cidr_ipv4         = "172.16.0.0/12"
  }
}

# Test 15: PASS - Standalone ingress rule with all protocols from specific CIDR
resource "aws_vpc_security_group_ingress_rule" "all_protocols_restricted" {
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "-1"
    cidr_ipv4         = "10.0.0.0/16"
  }
}
