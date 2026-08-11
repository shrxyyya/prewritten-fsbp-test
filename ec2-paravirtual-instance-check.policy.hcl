# Copyright IBM Corp. 2026

# Amazon EC2 paravirtual instance types should not be used


policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ec2-paravirtual-instance-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_instance" "no_paravirtual_instances" {
  enforcement_level = input.ec2-paravirtual-instance-check-enforcement-level
  locals {
    instance_ami_id = core::try(attrs.ami, "")
    all_amis = core::getresources("aws_ami", {})
    matching_amis = [
      for ami in local.all_amis :
      ami if core::try(ami.id, "") == local.instance_ami_id
    ]
    matched_ami = core::length(local.matching_amis) > 0 ? local.matching_amis[0] : null
    virtualization_type = core::try(local.matched_ami.virtualization_type, "")
    has_virtualization_type = local.virtualization_type != ""

    # Whether this AMI can be validated by the policy. If not, skip the check.
    can_validate = local.matched_ami != null && local.has_virtualization_type

    # Check if virtualization type is valid (hvm)
    is_hvm = local.virtualization_type == "hvm"
  }

  enforce {
    condition = !local.can_validate || local.is_hvm
    error_message = "EC2 instance uses AMI '${local.instance_ami_id}' with virtualization type '${local.virtualization_type}'. Paravirtual instances are not allowed. Use an HVM AMI instead"
  }
}
