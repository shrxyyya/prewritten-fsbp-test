# Copyright IBM Corp. 2026

# Classic Load Balancers should have connection draining enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elb-connection-draining-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_elb" "connection_draining_enabled" {
    enforcement_level = input.elb-connection-draining-enabled-enforcement-level
    locals {

        # Safe access to connection_draining attribute with default false
        # (matches AWS provider default behavior)
        connection_draining = core::try(attrs.connection_draining, false)
        elb_name = core::try(attrs.name, "Classic Load Balancer")
    }

    enforce {
        condition     = local.connection_draining == true
        error_message = "Classic Load Balancer '${local.elb_name}' must have connection draining enabled. Set 'connection_draining = true' in the resource configuration to ensure graceful handling of de-registering instances"
    }
}
