# Copyright IBM Corp. 2026

# ECS task definitions should have a logging configuration

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ecs-task-definition-log-configuration-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ecs_task_definition" "ecs_task_definition_logging_configured" {
    enforcement_level = input.ecs-task-definition-log-configuration-enforcement-level
    filter = attrs.container_definitions != null

    locals {
        container_defs = core::jsondecode(attrs.container_definitions)
        containers_with_invalid_logging = [
            for container in local.container_defs : container
            if core::try(container.logConfiguration.logDriver, "") == ""
        ]
        containers_with_logging_conf = [
            for container in local.container_defs : container
            if core::try(container.logConfiguration, null) == null
        ]
    }

    enforce {
        condition = (core::length(local.containers_with_logging_conf) == 0) && (core::length(local.containers_with_invalid_logging) ==0)
        error_message = "ECS task definition must configure logConfiguration.logDriver for every container"
    }
}