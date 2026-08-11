# Copyright IBM Corp. 2026

# ECS Task Definitions should use in-transit encryption for EFS volumes

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ecs-task-definition-efs-encryption-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ecs_task_definition" "efs_transit_encryption_enabled" {
    enforcement_level = input.ecs-task-definition-efs-encryption-enabled-enforcement-level
    locals {
        efs_volumes = [
            for vol in core::try(attrs.volume, []) : vol
            if core::try(vol.efs_volume_configuration, null) != null
        ]

        efs_volumes_without_encryption = [
            for vol in local.efs_volumes : vol
            if core::try(vol.efs_volume_configuration[0].transit_encryption, "DISABLED") != "ENABLED"
        ]
        
        # Check if task definition has any EFS volumes
        has_efs_volumes = core::length(core::try(local.efs_volumes, [])) > 0

        # Check if all EFS volumes have encryption enabled
        all_efs_encrypted = core::length(local.efs_volumes_without_encryption) == 0
    }

    # Only enforce if the task definition actually uses EFS volumes
    # Skip task definitions without EFS volumes (they pass by default)
    enforce {
        condition = !local.has_efs_volumes || local.all_efs_encrypted
        error_message = "ECS task definition has EFS volumes without transit encryption enabled"
    }
}
