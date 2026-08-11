# Copyright IBM Corp. 2026

# ECS task sets should not automatically assign public IP addresses

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ecs-taskset-assign-public-ip-disabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ecs_task_set" "no_public_ip" {
    enforcement_level = input.ecs-taskset-assign-public-ip-disabled-enforcement-level
    locals {
        has_network_config = core::length(core::try(attrs.network_configuration, [])) > 0
        assign_public_ip = core::try(attrs.network_configuration[0].assign_public_ip, false)
    }

    enforce {
        condition = !local.has_network_config || local.assign_public_ip == false
        error_message = "ECS task set has assign_public_ip set to true. Public IP addresses should not be automatically assigned to prevent unintended internet access"
    }
}
