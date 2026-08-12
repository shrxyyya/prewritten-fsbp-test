# Copyright IBM Corp. 2026

# Custom authorized TCP/UDP ports input scenario.

policytest {
  targets = ["vpc-sg-open-only-to-authorized-ports.policy.hcl"]
}

inputs {
  authorizedTcpPorts = "22,443"
  authorizedUdpPorts = "53"
}

# PASS: Security group allowing custom authorized TCP port 22
resource "aws_security_group" "pass_custom_tcp_22" {
  attrs = {
    name        = "test-sg-custom"
    description = "Test security group custom TCP"
    vpc_id      = "vpc-12345678"
    ingress = [
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

# PASS: Ingress rule allowing custom authorized UDP port 53
resource "aws_vpc_security_group_ingress_rule" "pass_custom_udp_53" {
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "udp"
    from_port         = 53
    to_port           = 53
    cidr_ipv4         = "0.0.0.0/0"
    description       = "Allow DNS"
  }
}

# FAIL: Ingress rule allowing TCP port 80 when custom inputs authorize only 22 and 443
resource "aws_vpc_security_group_ingress_rule" "fail_custom_tcp_80" {
  expect_failure = true
  attrs = {
    security_group_id = "sg-12345678"
    ip_protocol       = "tcp"
    from_port         = 80
    to_port           = 80
    cidr_ipv4         = "0.0.0.0/0"
    description       = "Allow HTTP"
  }
}
