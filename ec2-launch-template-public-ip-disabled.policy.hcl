# Copyright IBM Corp. 2026

# Amazon EC2 launch templates should not assign public IPs to network interfaces

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ec2-launch-template-public-ip-disabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_launch_template" "no_public_ip" {
    enforcement_level = input.ec2-launch-template-public-ip-disabled-enforcement-level
    filter = core::length(core::try(attrs.network_interfaces, [])) > 0

    locals {
        interfaces_with_public_ip = [
            for ni in core::try(attrs.network_interfaces, []) : ni
            if core::try(ni.associate_public_ip_address, false) == true
        ]
    }

    enforce {
        condition = core::length(local.interfaces_with_public_ip) == 0
        error_message = "Launch template has network interface(s) configured to assign public IP addresses. Set 'network_interfaces.associate_public_ip_address = false' or leave it unset to prevent public IP assignment and reduce internet exposure"
    }
}
