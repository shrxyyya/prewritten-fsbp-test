# Copyright IBM Corp. 2026

# Security groups should not allow unrestricted access to ports with high risk

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.56.0, < 7.0.0"
    }
  }
}

input "ec2-restricted-common-ports-enforcement-level" {
  type = string
  default = "advisory"
}

input "blocked_port1" {
    type = number
    default = 20
    description = "Blocked TCP port number. The default of 20 corresponds to File Transfer Protocol (FTP) Data Transfer."
}

input "blocked_port2" {
    type = number
    default = 21
    description = "Blocked TCP port number. The default of 21 corresponds to File Transfer Protocol (FTP) Command Control."
}

input "blocked_port3" {
    type = number
    default = 3389
    description = "Blocked TCP port number. The default of 3389 corresponds to Remote Desktop Protocol (RDP)."
}

input "blocked_port4" {
    type = number
    default = 3306
    description = "Blocked TCP port number. The default of 3306 corresponds to MySQL protocol."
}

input "blocked_port5" {
    type = number
    default = 4333
    description = "Blocked TCP port number. Used for a specific port relevant for your environment."
}

resource_policy "aws_vpc_security_group_ingress_rule" "no_unrestricted_high_risk_ports" {
  enforcement_level = input.ec2-restricted-common-ports-enforcement-level
  locals {
    blocked_ports_list = [20, 21, 22, 23, 25, 110, 135, 143, 445, 1433, 1434, 3000, 3306, 3389, 4333, 5000, 5432, 5500, 5601, 8080, 8088, 8888, 9200, 9300]

    # Check if rule allows unrestricted access
    is_unrestricted = (
      core::try(attrs.cidr_ipv4, "") == "0.0.0.0/0" ||
      core::try(attrs.cidr_ipv6, "") == "::/0"
    )

    from_port = core::try(attrs.from_port, 0)
    to_port = core::try(attrs.to_port, 65535)
    protocol = core::try(attrs.ip_protocol, "-1")

    exposed_ports_check = [
      for port in local.blocked_ports_list : port
      if (local.from_port <= port && local.to_port >= port)
    ]
    invalid_port1 = local.from_port <= input.blocked_port1 && local.to_port >= input.blocked_port1
    invalid_port2 = local.from_port <= input.blocked_port2 && local.to_port >= input.blocked_port2
    invalid_port3 = local.from_port <= input.blocked_port3 && local.to_port >= input.blocked_port3
    invalid_port4 = local.from_port <= input.blocked_port4 && local.to_port >= input.blocked_port4
    invalid_port5 = local.from_port <= input.blocked_port5 && local.to_port >= input.blocked_port5
    exposes_high_risk_port = (core::length(local.exposed_ports_check) > 0) || local.invalid_port1 || local.invalid_port2 || local.invalid_port3 || local.invalid_port4 || local.invalid_port5
    is_invalid_condition = local.protocol == "-1" || local.exposes_high_risk_port
  }

  enforce {
    condition = !(local.is_unrestricted && local.is_invalid_condition)
    error_message = "Security group ingress rule allows unrestricted access to high-risk ports"
  }
}
