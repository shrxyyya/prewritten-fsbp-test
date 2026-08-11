# Copyright IBM Corp. 2026

# Amazon EC2 subnets should not automatically assign public IP addresses

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "subnet-auto-assign-public-ip-disabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_subnet" "no_auto_public_ip" {
    enforcement_level = input.subnet-auto-assign-public-ip-disabled-enforcement-level
    locals {
        # Safe access to map_public_ip_on_launch attribute (defaults to false for non-default subnets)
        map_public_ip_on_launch = core::try(attrs.map_public_ip_on_launch, false)
        
        # Safe access to assign_ipv6_address_on_creation attribute (defaults to false)
        assign_ipv6_address_on_creation = core::try(attrs.assign_ipv6_address_on_creation, false)
        
        # Check if subnet auto-assigns IPv4 public IPs
        ipv4_violation = local.map_public_ip_on_launch == true
        
        # Check if subnet auto-assigns IPv6 addresses
        ipv6_violation = local.assign_ipv6_address_on_creation == true
  
    }

    enforce {
        condition = !local.ipv4_violation
        error_message = "Subnet violates EC2.15: map_public_ip_on_launch is set to true. Subnets should not automatically assign public IPv4 addresses to instances. Set map_public_ip_on_launch to false or remove the attribute (defaults to false)"
    }

    enforce {
        condition = !local.ipv6_violation
        error_message = "Subnet violates EC2.15: assign_ipv6_address_on_creation is set to true. Subnets should not automatically assign IPv6 addresses to instances. Set assign_ipv6_address_on_creation to false or remove the attribute (defaults to false)"
    }
}
