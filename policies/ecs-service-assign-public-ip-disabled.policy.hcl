# Copyright IBM Corp. 2026

# ECS services should not have public IP addresses assigned to them automatically

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ecs-service-assign-public-ip-disabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ecs_service" "no_public_ip" {
    enforcement_level = input.ecs-service-assign-public-ip-disabled-enforcement-level
    locals {
        has_network_config = core::try(attrs.network_configuration, null) != null && core::length(core::try(attrs.network_configuration, [])) > 0
    }

    enforce {
        condition = local.has_network_config ? !core::try(attrs.network_configuration[0].assign_public_ip, false) : true
        error_message = "ECS service has assign_public_ip set to true in network_configuration. This allows automatic public IP assignment, making the service reachable from the internet"
    }
}
