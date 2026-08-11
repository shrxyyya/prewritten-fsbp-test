# Copyright IBM Corp. 2026

# Classic Load Balancer should span multiple Availability Zones

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "clb-multiple-az-enforcement-level" {
  type = string
  default = "advisory"
}

input "clb_min_availability_zones" {
    type = number
    default = 2
}

resource_policy "aws_elb" "multiple_availability_zones" {
    enforcement_level = input.clb-multiple-az-enforcement-level
    locals {
        ec2_classic_az_count = core::try(core::length(attrs.availability_zones), 0)
        
        # For VPC ELBs: we need to count unique AZs from subnets
        # Since we cannot query subnet details in policy evaluation,
        # we count the number of subnets as a proxy
        # Note: This assumes each subnet is in a different AZ (common practice)
        vpc_subnet_count = core::try(core::length(attrs.subnets), 0)

        is_valid_input = core::contains([2, 3, 4, 5, 6], input.clb_min_availability_zones)
        
        # Use the appropriate count (whichever is greater than 0)
        actual_az_count = local.ec2_classic_az_count > 0 ? local.ec2_classic_az_count : local.vpc_subnet_count
    }

    enforce {
        condition = local.is_valid_input && (local.actual_az_count >= input.clb_min_availability_zones)
        error_message = "Classic Load Balancer does not span enough Availability Zones. Configure the load balancer to span at least 2 Availability Zones for high availability"
    }
}
