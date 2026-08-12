# Copyright IBM Corp. 2026

# Security groups should only allow unrestricted incoming traffic for authorized ports
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.56.0, < 7.0.0"
    }
  }
}

input "vpc-sg-open-only-to-authorized-ports-enforcement-level" {
  type = string
  default = "advisory"
}

input "authorizedTcpPorts" {
  type    = string
  default = "80,443"
}

input "authorizedUdpPorts" {
  type    = string
  default = ""
}

locals {
 
  authorized_tcp_ports = input.authorizedTcpPorts != "" ? [
    for p in core::split(",", input.authorizedTcpPorts) : core::try(core::jsondecode(core::trimspace(p)), -1)
  ] : []

  authorized_udp_ports = input.authorizedUdpPorts != "" ? [
    for p in core::split(",", input.authorizedUdpPorts) : core::try(core::jsondecode(core::trimspace(p)), -1)
  ] : []

  # Input validation: lists must contain between 1 and 32 entries (UDP may be empty),
  # and every entry must have parsed to a non-negative integer.
  valid_tcp_port_count   = core::length(local.authorized_tcp_ports) >= 1 && core::length(local.authorized_tcp_ports) <= 32
  tcp_ports_all_numeric  = core::length([for p in local.authorized_tcp_ports : p if p == -1]) == 0
  valid_tcp_ports        = local.valid_tcp_port_count && local.tcp_ports_all_numeric

  valid_udp_port_count   = input.authorizedUdpPorts == "" || (core::length(local.authorized_udp_ports) >= 1 && core::length(local.authorized_udp_ports) <= 32)
  udp_ports_all_numeric  = core::length([for p in local.authorized_udp_ports : p if p == -1]) == 0
  valid_udp_ports        = local.valid_udp_port_count && local.udp_ports_all_numeric

  public_ipv4_cidr_pattern = "^0\\.0\\.0\\.0/[0-7]$"
  public_ipv6_cidr_pattern = "^::/[0-7]$"
}

resource_policy "aws_security_group" "restrict_unrestricted_ingress" {
  enforcement_level = input.vpc-sg-open-only-to-authorized-ports-enforcement-level
  filter = core::length(core::try(attrs.ingress, [])) > 0

  locals {
    ingress_rules = core::try(attrs.ingress, [])

    # Ingress rules that allow unrestricted IPv4 or IPv6 access. A rule counts as
    # "unrestricted" when ANY of its cidr_blocks / ipv6_cidr_blocks entries matches
    # the broadly-public patterns above (0.0.0.0/0-7 or ::/0-7), not just the
    # literal /0 strings.
    unrestricted_ingress_rules = [
      for rule in local.ingress_rules :
      rule
      if core::length([
        for c in core::try(rule.cidr_blocks, []) :
        c if core::length(core::regexall(local.public_ipv4_cidr_pattern, c)) > 0
      ]) > 0
      || core::length([
        for c in core::try(rule.ipv6_cidr_blocks, []) :
        c if core::length(core::regexall(local.public_ipv6_cidr_pattern, c)) > 0
      ]) > 0
    ]

    # A rule is compliant when its protocol is TCP or UDP, its port range is a
    # single port (from_port == to_port), and that port is in the relevant
    # authorized list. Protocol "-1" (all) is never compliant for an
    # unrestricted CIDR.
    unauthorized_rules = [
      for rule in local.unrestricted_ingress_rules :
      rule
      if !(
        (
          core::try(rule.protocol, "") == "tcp"
          && core::try(rule.from_port, -1) == core::try(rule.to_port, -1)
          && core::contains(local.authorized_tcp_ports, core::try(rule.from_port, -1))
        )
        || (
          core::try(rule.protocol, "") == "udp"
          && core::try(rule.from_port, -1) == core::try(rule.to_port, -1)
          && core::contains(local.authorized_udp_ports, core::try(rule.from_port, -1))
        )
      )
    ]
  }

  enforce {
    condition     = local.valid_tcp_ports
    error_message = "input.authorizedTcpPorts must be a comma-separated list of 1 to 32 numeric TCP port values."
  }

  enforce {
    condition     = local.valid_udp_ports
    error_message = "input.authorizedUdpPorts must be empty or a comma-separated list of 1 to 32 numeric UDP port values."
  }

  enforce {
    condition     = core::length(local.unauthorized_rules) == 0
    error_message = "Security group has ingress rules that allow unrestricted incoming traffic from a broadly-public CIDR (0.0.0.0/0-7 or ::/0-7) on ports outside the authorized TCP/UDP lists"
  }
}

resource_policy "aws_vpc_security_group_ingress_rule" "restrict_unrestricted_ingress" {
  enforcement_level = input.vpc-sg-open-only-to-authorized-ports-enforcement-level
  # Match any broadly-public CIDR on either IP family, not only the literal
  # "0.0.0.0/0" / "::/0" strings (see public_ipv4_cidr_pattern above).
  filter = (core::length(core::regexall(local.public_ipv4_cidr_pattern, local.cidr_ipv4)) > 0) || (core::length(core::regexall(local.public_ipv6_cidr_pattern, local.cidr_ipv6)) > 0)

  locals {
    cidr_ipv4 = core::try(attrs.cidr_ipv4, "") != null ? core::try(attrs.cidr_ipv4, "") : ""
    cidr_ipv6 = core::try(attrs.cidr_ipv6, "") != null ? core::try(attrs.cidr_ipv6, "") : ""
    protocol  = core::try(attrs.ip_protocol, "")
    from_port = core::try(attrs.from_port, -1)
    to_port   = core::try(attrs.to_port, -1)

    is_tcp_authorized = (
      local.protocol == "tcp"
      && local.from_port == local.to_port
      && core::contains(local.authorized_tcp_ports, local.from_port)
    )

    is_udp_authorized = (
      local.protocol == "udp"
      && local.from_port == local.to_port
      && core::contains(local.authorized_udp_ports, local.from_port)
    )

    is_authorized = local.is_tcp_authorized || local.is_udp_authorized
  }

  enforce {
    condition     = local.valid_tcp_ports
    error_message = "input.authorizedTcpPorts must be a comma-separated list of 1 to 32 numeric TCP port values."
  }

  enforce {
    condition     = local.valid_udp_ports
    error_message = "input.authorizedUdpPorts must be empty or a comma-separated list of 1 to 32 numeric UDP port values."
  }

  enforce {
    condition     = local.is_authorized
    error_message = "Security group ingress rule allows unrestricted incoming traffic from a broadly-public CIDR (0.0.0.0/0-7 or ::/0-7) on a port outside the authorized TCP/UDP lists"
  }
}
