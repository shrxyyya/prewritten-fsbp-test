# Copyright IBM Corp. 2026

# ECS capacity providers should have managed termination protection enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ecs-capacity-provider-termination-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ecs_capacity_provider" "managed_termination_protection_enabled" {
    enforcement_level = input.ecs-capacity-provider-termination-check-enforcement-level
    # Only evaluate capacity providers that use auto_scaling_group_provider
    # (managed_instances_provider doesn't support managed_termination_protection)
    filter = core::try(attrs.auto_scaling_group_provider, null) != null

    locals {
        # Safely extract managed_termination_protection value
        # Default to "DISABLED" if not specified
        termination_protection = core::try(
            attrs.auto_scaling_group_provider[0].managed_termination_protection,
            "DISABLED"
        )
        
        # Check if managed_scaling is enabled (required for termination protection to work)
        managed_scaling_status = core::try(
            attrs.auto_scaling_group_provider[0].managed_scaling[0].status,
            "DISABLED"
        )
    }

    # Enforce that managed_termination_protection is ENABLED
    enforce {
        condition = local.termination_protection == "ENABLED"
        error_message = "ECS capacity provider must have managed_termination_protection set to 'ENABLED'. This protects instances with running tasks from being terminated during scale-in operations"
    }

    # Enforce that managed_scaling is also enabled (required for termination protection)
    enforce {
        condition = local.managed_scaling_status == "ENABLED"
        error_message = "ECS capacity provider must have managed_scaling.status set to 'ENABLED' for managed_termination_protection to work properly. Managed termination protection requires managed scaling to be enabled"
    }
}
