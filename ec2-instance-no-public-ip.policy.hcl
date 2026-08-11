# Copyright IBM Corp. 2026

# Amazon EC2 instances should not have a public IPv4 address

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ec2-instance-no-public-ip-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_instance" "no_public_ipv4" {
  enforcement_level = input.ec2-instance-no-public-ip-enforcement-level
  locals {
    # Safe access to associate_public_ip_address attribute
    # This attribute explicitly controls public IP assignment
    has_public_ip_setting = core::try(attrs.associate_public_ip_address, null)
    
    # Check if explicitly set to true (violation)
    explicitly_public = local.has_public_ip_setting == true
    
    # Check for network_interface blocks that might have public IP associations
    # network_interface is deprecated but still supported
    network_interfaces = core::try(attrs.network_interface, [])
    
    # Filter network interfaces that have public IP enabled
    public_network_interfaces = [
      for ni in local.network_interfaces :
      ni if core::try(ni.associate_public_ip_address, false) == true
    ]
    
    # Check if any network interface has associate_public_ip_address set to true
    has_public_ni = core::length(local.public_network_interfaces) > 0
    
    is_compliant = !local.explicitly_public && !local.has_public_ni
  }

  enforce {
    condition     = local.is_compliant
    error_message = "EC2 instance must not have a public IPv4 address. Either 'associate_public_ip_address' is set to true or a network_interface has public IP association enabled, which violates security policy EC2.9. Use a non-default VPC and ensure instances are launched in subnets that do not auto-assign public IPs. Remove explicit public IP associations from instance and network interface configurations"
  }
}
