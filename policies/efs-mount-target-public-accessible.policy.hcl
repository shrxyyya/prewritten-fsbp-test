# Copyright IBM Corp. 2026

# EFS mount targets should not be associated with subnets that assign public IP addresses on launch

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "efs-mount-target-public-accessible-enforcement-level" {
  type = string
  default = "advisory"
}

locals {
    efs_all_subnets = core::getresources("aws_subnet", {})
}

resource_policy "aws_efs_mount_target" "no_public_subnet" {
    enforcement_level = input.efs-mount-target-public-accessible-enforcement-level
    locals {
        subnet = core::try(
            [for s in local.efs_all_subnets : s if s.id == attrs.subnet_id][0],
            null
        )
        map_public_ip_on_launch = core::try(local.subnet.map_public_ip_on_launch, false)
    }

    enforce {
        condition     = !local.map_public_ip_on_launch
        error_message = "EFS mount target is associated with a subnet that assigns public IPv4 addresses on launch (map_public_ip_on_launch=true). Mount targets must only be placed in subnets that do not auto-assign public IPs"
    }
}
