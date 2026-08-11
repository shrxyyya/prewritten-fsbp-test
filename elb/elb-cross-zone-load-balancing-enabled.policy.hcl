# Copyright IBM Corp. 2026

# Classic Load Balancers should have cross-zone load balancing enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elb-cross-zone-load-balancing-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_elb" "cross_zone_load_balancing_enabled" {
    enforcement_level = input.elb-cross-zone-load-balancing-enabled-enforcement-level
    enforce {
        condition = core::try(attrs.cross_zone_load_balancing, true) == true
        error_message = "Classic Load Balancer does not have cross-zone load balancing enabled. Set 'cross_zone_load_balancing = true' to ensure even traffic distribution across all Availability Zones"
    }
}
