# Copyright IBM Corp. 2026

# Amazon EMR cluster primary nodes should not have public IP addresses

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "emr-master-no-public-ip-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_emr_cluster" "emr_master_no_public_ip" {
  enforcement_level = input.emr-master-no-public-ip-enforcement-level
  
  locals {
    cluster_name = core::try(attrs.name, "Amazon EMR cluster")

    ec2_attrs     = core::try(attrs.ec2_attributes, {})
    has_ec2_attrs = core::length(core::keys(local.ec2_attrs)) > 0

    subnet_id  = local.has_ec2_attrs ? core::try(local.ec2_attrs.subnet_id, null) : null
    subnet_ids = local.has_ec2_attrs ? core::try(local.ec2_attrs.subnet_ids, []) : []

    candidate_subnets = local.subnet_id != null ? [local.subnet_id] : local.subnet_ids

    emr_all_subnets = core::getresources("aws_subnet", {})

    matching_subnets = [
      for subnet in local.emr_all_subnets :
      subnet if core::contains(local.candidate_subnets, subnet.id)
    ]

    public_matching_subnets = [
      for s in local.matching_subnets :
      s if core::try(s.map_public_ip_on_launch, false)
    ]

    any_subnet_assigns_public_ip = core::length(local.public_matching_subnets) > 0
  }

  enforce {
    condition = core::length(local.candidate_subnets) > 0
    error_message = "EMR cluster must be launched in a VPC subnet. Configure ec2_attributes with subnet_id or subnet_ids"
  }

  enforce {
    condition = !local.any_subnet_assigns_public_ip
    error_message = "EMR cluster master nodes must not have public IP addresses. One or more subnets configured in ec2_attributes have map_public_ip_on_launch enabled. Launch the cluster only in private subnets with map_public_ip_on_launch set to false"
  }
}
