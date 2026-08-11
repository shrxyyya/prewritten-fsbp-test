# Copyright IBM Corp. 2026

# ECS task definitions should configure containers to be limited to read-only access to root filesystems

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ecs-containers-readonly-access-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ecs_task_definition" "readonly_root_filesystem" {
    enforcement_level = input.ecs-containers-readonly-access-enforcement-level
    filter = attrs.container_definitions != null

    locals {
        container_defs = core::jsondecode(attrs.container_definitions)
        
        # Check each container for readonlyRootFilesystem setting
        # A container is compliant if readonlyRootFilesystem is explicitly set to true
        containers_with_no_readonly = [
            for container in local.container_defs : container
            if core::try(container.readonlyRootFilesystem, false) == false
        ]
    }

    enforce {
        condition = core::length(local.containers_with_no_readonly) == 0
        error_message = "ECS task definition contains one or more containers with readonlyRootFilesystem value set to false"
    }
}
