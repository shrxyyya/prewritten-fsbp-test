# Copyright IBM Corp. 2026

# VPC default security groups should not allow inbound or outbound traffic

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.56.0, < 7.0.0"
    }
  }
}

input "vpc-default-security-group-closed-enforcement-level" {
  type = string
  default = "advisory"
}

# Cache all security group rules for performance
locals {
  all_ingress_rules = core::getresources("aws_vpc_security_group_ingress_rule", {})
  all_egress_rules = core::getresources("aws_vpc_security_group_egress_rule", {})
  all_legacy_rules = core::getresources("aws_security_group_rule", {})
}

resource_policy "aws_default_security_group" "no_traffic_allowed" {
  enforcement_level = input.vpc-default-security-group-closed-enforcement-level
  locals {
    # Check if ingress block is present and not empty
    has_ingress_block = core::try(core::length(attrs.ingress), 0) > 0
    
    # Check if egress block is present and not empty
    has_egress_block = core::try(core::length(attrs.egress), 0) > 0
    
    # Find any separate ingress rules that reference this default security group
    matching_ingress_rules = [
      for rule in local.all_ingress_rules :
      rule if rule.security_group_id == attrs.id
    ]
    
    # Find any separate egress rules that reference this default security group
    matching_egress_rules = [
      for rule in local.all_egress_rules :
      rule if rule.security_group_id == attrs.id
    ]
    
    # Find any legacy security group rules that reference this default security group
    matching_legacy_rules = [
      for rule in local.all_legacy_rules :
      rule if rule.security_group_id == attrs.id
    ]
    
    # Check if any external rules exist
    has_external_ingress = core::length(local.matching_ingress_rules) > 0
    has_external_egress = core::length(local.matching_egress_rules) > 0
    has_legacy_rules = core::length(local.matching_legacy_rules) > 0
    
    # Overall compliance check
    is_compliant = !local.has_ingress_block && !local.has_egress_block && !local.has_external_ingress && !local.has_external_egress && !local.has_legacy_rules
  }

  enforce {
    condition = !local.has_ingress_block
    error_message = "Default security group must not have any ingress rules defined in the ingress block. Remove all ingress rules from the default security group"
  }

  enforce {
    condition = !local.has_egress_block
    error_message = "Default security group must not have any egress rules defined in the egress block. Remove all egress rules from the default security group"
  }

  enforce {
    condition = !local.has_external_ingress
    error_message = "Default security group must not have any separate aws_vpc_security_group_ingress_rule resources. Found ${core::length(local.matching_ingress_rules)} ingress rule(s). Remove all ingress rules"
  }

  enforce {
    condition = !local.has_external_egress
    error_message = "Default security group must not have any separate aws_vpc_security_group_egress_rule resources. Found ${core::length(local.matching_egress_rules)} egress rule(s). Remove all egress rules"
  }

  enforce {
    condition = !local.has_legacy_rules
    error_message = "Default security group must not have any aws_security_group_rule resources. Found ${core::length(local.matching_legacy_rules)} rule(s). Remove all security group rules"
  }
}
