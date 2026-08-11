# Copyright IBM Corp. 2026

# Network ACLs should not allow ingress from 0.0.0.0/0 to port 22 or port 3389

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ec2-nacl-no-unrestricted-ssh-rdp-enforcement-level" {
  type = string
  default = "advisory"
}

# Check inline ingress rules in aws_network_acl resources
resource_policy "aws_network_acl" "no_unrestricted_ssh_rdp" {
    enforcement_level = input.ec2-nacl-no-unrestricted-ssh-rdp-enforcement-level
    filter = core::length(core::try(attrs.ingress, [])) > 0

    locals {
        # Filter for SSH rules (port 22) with unrestricted access
        tcp_ssh_unrestricted = [
            for rule in attrs.ingress :
            rule if (
                rule.action == "allow" &&
                (rule.protocol == "tcp" || rule.protocol == "-1") &&
                core::try(rule.from_port, 0) <= 22 &&
                core::try(rule.to_port, 0) >= 22 &&
                (core::try(rule.cidr_block, "") == "0.0.0.0/0" || core::try(rule.ipv6_cidr_block, "") == "::/0")
            )
        ]

        # Filter for RDP rules (port 3389) with unrestricted access
        tcp_rdp_unrestricted = [
            for rule in attrs.ingress :
            rule if (
                rule.action == "allow" &&
                (rule.protocol == "tcp" || rule.protocol == "-1") &&
                core::try(rule.from_port, 0) <= 3389 &&
                core::try(rule.to_port, 0) >= 3389 &&
                (core::try(rule.cidr_block, "") == "0.0.0.0/0" || core::try(rule.ipv6_cidr_block, "") == "::/0")
            )
        ]

        udp_ssh_unrestricted = [
            for rule in attrs.ingress :
            rule if (
                rule.action == "allow" &&
                (rule.protocol == "udp" || rule.protocol == "-1") &&
                core::try(rule.from_port, 0) <= 22 &&
                core::try(rule.to_port, 0) >= 22 &&
                (core::try(rule.cidr_block, "") == "0.0.0.0/0" || core::try(rule.ipv6_cidr_block, "") == "::/0")
            )
        ]

        udp_rdp_unrestricted = [
            for rule in attrs.ingress :
            rule if (
                rule.action == "allow" &&
                (rule.protocol == "udp" || rule.protocol == "-1") &&
                core::try(rule.from_port, 0) <= 3389 &&
                core::try(rule.to_port, 0) >= 3389 &&
                (core::try(rule.cidr_block, "") == "0.0.0.0/0" || core::try(rule.ipv6_cidr_block, "") == "::/0")
            )
        ]

        has_unrestricted_ssh = core::length(local.tcp_ssh_unrestricted) > 0 || core::length(local.udp_ssh_unrestricted) > 0
        has_unrestricted_rdp = core::length(local.tcp_rdp_unrestricted) > 0 || core::length(local.udp_rdp_unrestricted) > 0
    }

    enforce {
        condition = !local.has_unrestricted_ssh
        error_message = "Network ACL allows unrestricted SSH access (port 22) from 0.0.0.0/0 or ::/0. Remove or restrict the ingress rule to specific CIDR blocks"
    }

    enforce {
        condition = !local.has_unrestricted_rdp
        error_message = "Network ACL allows unrestricted RDP access (port 3389) from 0.0.0.0/0 or ::/0. Remove or restrict the ingress rule to specific CIDR blocks"
    }
}

resource_policy "aws_network_acl_rule" "no_unrestricted_ssh_rdp" {
    enforcement_level = input.ec2-nacl-no-unrestricted-ssh-rdp-enforcement-level
    # Only check ingress rules (egress = false or not set) with allow action
    filter = core::try(attrs.egress, false) == false && attrs.rule_action == "allow"

    locals {
        from_port = core::try(attrs.from_port, 0)
        to_port = core::try(attrs.to_port, 0)
        cidr_block = core::try(attrs.cidr_block, "")
        ipv6_cidr_block = core::try(attrs.ipv6_cidr_block, "")
        
        is_unrestricted = local.cidr_block == "0.0.0.0/0" || local.ipv6_cidr_block == "::/0"
        allows_ssh = local.from_port <= 22 && local.to_port >= 22
        allows_rdp = local.from_port <= 3389 && local.to_port >= 3389
    }

    enforce {
        condition = (core::try(attrs.protocol, "") == "tcp" || core::try(attrs.protocol, "") == "udp") && !(local.is_unrestricted && local.allows_ssh)
        error_message = "Network ACL rule allows unrestricted SSH access (port 22) from 0.0.0.0/0 or ::/0. Change the cidr_block or ipv6_cidr_block to a specific range"
    }

    enforce {
        condition = (core::try(attrs.protocol, "") == "tcp" || core::try(attrs.protocol, "") == "udp") && !(local.is_unrestricted && local.allows_rdp)
        error_message = "Network ACL rule allows unrestricted RDP access (port 3389) from 0.0.0.0/0 or ::/0. Change the cidr_block or ipv6_cidr_block to a specific range"
    }
}