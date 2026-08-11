# Copyright IBM Corp. 2026

# Unused Network Access Control Lists should be removed

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "vpc-network-acl-unused-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_network_acl" "unused_nacl_check" {
  enforcement_level = input.vpc-network-acl-unused-check-enforcement-level

  locals {
    # Check if subnet_ids attribute exists and has associations
    has_direct_subnet_associations = core::try(
      attrs.subnet_ids != null && core::length(attrs.subnet_ids) > 0,
      false
    )
  }

  enforce {
    condition     = local.has_direct_subnet_associations
    error_message = "Network ACL is unused and should be removed. Non-default network ACLs must be associated with at least one subnet via the subnet_ids attribute. Unused network ACLs should be deleted to maintain a clean infrastructure"
  }
}


resource_policy "aws_default_network_acl" "allow_default_nacl" {
  enforcement_level = input.vpc-network-acl-unused-check-enforcement-level
  
  enforce {
    condition     = true
    error_message = "This should never fail - default network ACLs are always compliant"
  }
}